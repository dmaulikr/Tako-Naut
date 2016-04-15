//
//  PNEnemy.m
//  Psynaut
//
//  Created by mugx on 23/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNEnemy.h"
#import "PNPlayer.h"
#import "PNMacros.h"

#define ANIM_TIME 0.5

typedef struct
{
  CGRect frame;
  char direction;
} PossibleDirection;

typedef struct
{
  CGRect frame;
  int cost;
} Node;

@interface PNEnemy()
@property(nonatomic,strong) NSMutableArray *exploredTiles;
@property(nonatomic,assign) BOOL exploding;
@property(nonatomic,assign) float timeAccumulator;
@property(nonatomic,assign) char lastDirection;
@end

@implementation PNEnemy

CGFloat distance( CGRect rect1, CGRect rect2 )
{
  // return fabs(rect1.origin.x - rect2.origin.x) + fabs(rect1.origin.y - rect2.origin.y);
  CGPoint center1 = CGPointMake( CGRectGetMidX( rect1 ), CGRectGetMidY( rect1 ) );
  CGPoint center2 = CGPointMake( CGRectGetMidX( rect2 ), CGRectGetMidY( rect2 ) );
  CGFloat horizontalDistance = ( center2.x - center1.x );
  CGFloat verticalDistance = ( center2.y - center1.y );
  CGFloat distance = sqrt( ( horizontalDistance * horizontalDistance ) + ( verticalDistance * verticalDistance ) );
  return distance;
}

- (instancetype)initWithFrame:(CGRect)frame withGameSession:(PNGameSession *)gameSession
{
  self = [super initWithFrame:frame];
  _exploredTiles = [NSMutableArray array];
  
  self.gameSession = gameSession;
  self.speed = ENEMY_SPEED;
  self.velocity = CGPointMake(0, 0);
  return self;
}

- (void)exploreCurrentTile
{
  int x = (int)roundf(self.frame.origin.x / TILE_SIZE);
  int y = (int)roundf(self.frame.origin.y / TILE_SIZE);
  NSValue *currentTile = [NSValue valueWithCGPoint:CGPointMake(x, y)];
  if (![self.exploredTiles containsObject:currentTile])
  {
    [self.exploredTiles addObject:currentTile];
  }
}

- (char)getBestDirection:(NSArray *)directions targetFrame:(CGRect)targetFrame
{
  CGFloat bestManhattan = FLT_MAX;
  char bestDirection = ' ';
  for (NSDictionary * direction in directions)
  {
    CGRect frame = [direction[@"frame"] CGRectValue];
    CGFloat manhattan = distance(frame, targetFrame);
    if (manhattan < bestManhattan)
    {
      bestManhattan = manhattan;
      bestDirection = [direction[@"move"] charValue];
    }
  }
  return bestDirection;
}

- (BOOL)checkExploredCollision:(CGRect)targetFrame
{
  for (NSValue *val in self.exploredTiles)
  {
    if (CGRectIntersectsRect(targetFrame, [val CGRectValue]))
    {
      return YES;
      break;
    }
  }
  return NO;
}

- (void)search_corridors:(CGRect)targetFrame
{
  bool playerFound = false;
  targetFrame = CGRectMake((int)floorf(targetFrame.origin.x / TILE_SIZE) * TILE_SIZE, (int)floorf(targetFrame.origin.y / TILE_SIZE) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
  CGRect oldFrame = CGRectMake((int)floorf(self.frame.origin.x / TILE_SIZE) * TILE_SIZE, (int)floorf(self.frame.origin.y / TILE_SIZE) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
  CGRect currentFrame = CGRectMake((int)floorf(self.frame.origin.x / TILE_SIZE) * TILE_SIZE, (int)floorf(self.frame.origin.y / TILE_SIZE) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
  CGFloat currentSpeed = TILE_SIZE;
  CGFloat currentSize = TILE_SIZE;
  //CGRect oldFrame = self.frame;
  //CGRect currentFrame = self.frame;
  //CGFloat currentSpeed = self.speed;
  //CGFloat currentSize = self.frame.size.width;
  NSMutableArray *visited = [@[[NSValue valueWithCGRect:currentFrame]] mutableCopy];
  self.exploredTiles = [@[[NSValue valueWithCGRect:currentFrame]] mutableCopy];
  while (!playerFound)
  {
    for (NSValue *val in visited)
    {
      if (CGRectIntersectsRect(targetFrame, [val CGRectValue]))
      {
        playerFound = true;
        break;
      }
    }
    
    if (playerFound)
    {
      [visited removeObject:[NSValue valueWithCGRect:oldFrame]];
      self.exploredTiles = visited;
    }
    else
    {
      CGRect eastFrame = CGRectMake(currentFrame.origin.x - currentSpeed, currentFrame.origin.y, currentSize, currentSize);
      CGRect westFrame = CGRectMake(currentFrame.origin.x + currentSpeed, currentFrame.origin.y, currentSize, currentSize);
      CGRect northFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y - currentSpeed, currentSize, currentSize);
      CGRect southFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y + currentSpeed, currentSize, currentSize);
      BOOL collidesEast = [self collidesEastOf:currentFrame] || [self.exploredTiles containsObject:[NSValue valueWithCGRect:eastFrame]];
      BOOL collidesWest = [self collidesWestOf:currentFrame] || [self.exploredTiles containsObject:[NSValue valueWithCGRect:westFrame]];
      BOOL collidesNorth = [self collidesNorthOf:currentFrame] || [self.exploredTiles containsObject:[NSValue valueWithCGRect:northFrame]];
      BOOL collidesSouth = [self collidesSouthOf:currentFrame] || [self.exploredTiles containsObject:[NSValue valueWithCGRect:southFrame]];
      
      NSMutableArray *possibleDirections = [NSMutableArray array];
      /*
      if (!collidesEast) [possibleDirections addObject:@{@"move":@('e'), @"frame":[NSValue valueWithCGRect:eastFrame]}];
      if (!collidesWest) [possibleDirections addObject:@{@"move":@('w'), @"frame":[NSValue valueWithCGRect:westFrame]}];
      if (!collidesNorth) [possibleDirections addObject:@{@"move":@('n'), @"frame":[NSValue valueWithCGRect:northFrame]}];
      if (!collidesSouth) [possibleDirections addObject:@{@"move":@('s'), @"frame":[NSValue valueWithCGRect:southFrame]}];
      */
      
       if (!collidesEast) [possibleDirections addObject:@('e')];
       if (!collidesWest) [possibleDirections addObject:@('w')];
       if (!collidesSouth) [possibleDirections addObject:@('s')];
       if (!collidesNorth) [possibleDirections addObject:@('n')];      
      if (possibleDirections.count > 0)
      {
        char bestDestination = [self getBestDirection:possibleDirections targetFrame:targetFrame];
        switch(bestDestination)
        //switch([possibleDirections[arc4random() % possibleDirections.count] charValue])
        {
          case 'n':
            currentFrame = northFrame;
            break;
          case 's':
            currentFrame = southFrame;
            break;
          case 'e':
            currentFrame = eastFrame;
            break;
          case 'w':
            currentFrame = westFrame;
            break;
        }
        
        //CGRect currentFrameCentered = CGRectMake((int)roundf(currentFrame.origin.x / TILE_SIZE) * TILE_SIZE, (int)roundf(currentFrame.origin.y / TILE_SIZE) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
        CGRect currentFrameCentered = currentFrame;
        NSValue *currentTile = [NSValue valueWithCGRect:currentFrameCentered];
        if (![self.exploredTiles containsObject:currentTile])
        {
          [self.exploredTiles addObject:currentTile];
          [visited addObject:currentTile];
        }
      }
      else
      {
        NSValue *currentTile = [visited lastObject];
        if (visited.count == 1)
        {
          [self.exploredTiles removeAllObjects];
          return;
        }
        else if (currentTile)
        {
          currentFrame = [currentTile CGRectValue];
          [visited removeLastObject];
        }
      }
    }
  }
}

- (void)update:(CGFloat)deltaTime
{
  self.timeAccumulator += deltaTime;
  
  // if (self.timeAccumulator > 0.1)
  {
    //   self.timeAccumulator = 0;
    PNPlayer *player = self.gameSession.player;
    [self search_corridors:player.frame];
    if (self.exploredTiles.count > 0)
    {
      CGRect nextFrame = [self.exploredTiles.firstObject CGRectValue];
      CGRect eastFrame = CGRectMake(self.frame.origin.x - self.speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
      CGRect westFrame = CGRectMake(self.frame.origin.x  + self.speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
      CGRect northFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.speed, self.frame.size.width, self.frame.size.height);
      CGRect southFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.speed, self.frame.size.width, self.frame.size.height);
      BOOL collidesEast = [self checkWallCollision:eastFrame];
      BOOL collidesWest = [self checkWallCollision:westFrame];
      BOOL collidesNorth = [self checkWallCollision:northFrame];
      BOOL collidesSouth = [self checkWallCollision:southFrame];
      
      NSMutableArray *possibleDirections = [NSMutableArray array];
      if (!collidesEast && self.lastDirection != 'w') [possibleDirections addObject:@{@"move":@('e'), @"frame":[NSValue valueWithCGRect:eastFrame]}];
      if (!collidesWest && self.lastDirection != 'e') [possibleDirections addObject:@{@"move":@('w'), @"frame":[NSValue valueWithCGRect:westFrame]}];
      if (!collidesNorth && self.lastDirection != 's') [possibleDirections addObject:@{@"move":@('n'), @"frame":[NSValue valueWithCGRect:northFrame]}];
      if (!collidesSouth && self.lastDirection != 'n') [possibleDirections addObject:@{@"move":@('s'), @"frame":[NSValue valueWithCGRect:southFrame]}];
      
      char bestDirection = [self getBestDirection:possibleDirections targetFrame:nextFrame];
      self.lastDirection = bestDirection;
      switch (bestDirection)
      {
        case 'e':
          [self didSwipe:UISwipeGestureRecognizerDirectionLeft];
          break;
        case 'w':
          [self didSwipe:UISwipeGestureRecognizerDirectionRight];
          break;
        case 'n':
          [self didSwipe:UISwipeGestureRecognizerDirectionUp];
          break;
        case 's':
          [self didSwipe:UISwipeGestureRecognizerDirectionDown];
          break;
      }
    }
  }
  [super update:deltaTime];
}

@end