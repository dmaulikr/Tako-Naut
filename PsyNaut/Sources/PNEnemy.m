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
#import "PNTile+AI.h"

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
@property(nonatomic,assign) BOOL exploding;
@property(nonatomic,strong) NSMutableArray *path;
@property(nonatomic,assign) float timeAccumulator;
@end

@implementation PNEnemy

CGFloat distance( CGRect rect1, CGRect rect2 )
{
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
  self.gameSession = gameSession;
  self.speed = ENEMY_SPEED;
  self.velocity = CGPointMake(0, 0);
  return self;
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

- (bool)isPlayerFound:(CGRect)target visited:(NSArray *)visited
{
  for (NSValue *val in visited)
  {
    if (CGRectIntersectsRect(target, [val CGRectValue]))
    {
      return true;
    }
  }
  return false;
}

/*
 - (void)search:(CGRect)targetFrame
 {
 bool playerFound = false;
 targetFrame = CGRectMake((int)roundf(targetFrame.origin.x / TILE_SIZE) * TILE_SIZE, (int)floorf(targetFrame.origin.y / TILE_SIZE) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
 CGRect oldFrame = CGRectMake((int)roundf(self.frame.origin.x / TILE_SIZE) * TILE_SIZE, (int)floorf(self.frame.origin.y / TILE_SIZE) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
 CGRect currentFrame = CGRectMake((int)roundf(self.frame.origin.x / TILE_SIZE) * TILE_SIZE, (int)floorf(self.frame.origin.y / TILE_SIZE) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
 CGFloat currentSpeed = TILE_SIZE;
 CGFloat currentSize = TILE_SIZE;
 char lastDirection = ' ';
 NSMutableArray *visited = [@[[NSValue valueWithCGRect:currentFrame]] mutableCopy];
 self.exploredTiles = [@[[NSValue valueWithCGRect:currentFrame]] mutableCopy];
 while (!playerFound)
 {
 playerFound = [self isPlayerFound:targetFrame visited:visited];
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
 if (!collidesEast && lastDirection != 'w') [possibleDirections addObject:@{@"move":@('e'), @"frame":[NSValue valueWithCGRect:eastFrame]}];
 if (!collidesWest && lastDirection != 'e') [possibleDirections addObject:@{@"move":@('w'), @"frame":[NSValue valueWithCGRect:westFrame]}];
 if (!collidesNorth && lastDirection != 's') [possibleDirections addObject:@{@"move":@('n'), @"frame":[NSValue valueWithCGRect:northFrame]}];
 if (!collidesSouth && lastDirection != 'n') [possibleDirections addObject:@{@"move":@('s'), @"frame":[NSValue valueWithCGRect:southFrame]}];
 if (possibleDirections.count > 0)
 {
 lastDirection = [self getBestDirection:possibleDirections targetFrame:targetFrame];
 switch(lastDirection)
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
 //--- deadlock ---//
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
 */

- (void)update:(CGFloat)deltaTime
{
  self.timeAccumulator += deltaTime;
  if (self.timeAccumulator > 3 || !self.path || self.path.count == 0)
  {
    self.timeAccumulator = 0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      PNPlayer *player = self.gameSession.player;
      self.path = [NSMutableArray arrayWithArray:[self search:player.frame]];
    });
  }
  
  if (self.path.count > 0)
  {
    CGRect originalFrame = CGRectMake((int)roundf(self.frame.origin.x / TILE_SIZE) * TILE_SIZE, (int)floorf(self.frame.origin.y / TILE_SIZE) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
    CGRect nextFrame = [self.path.firstObject CGRectValue];
    if ([self collidesTarget:originalFrame cells:self.path])
    {
      [self.path removeObject:[NSValue valueWithCGRect:originalFrame]];
    }
    
    CGRect eastFrame = CGRectMake(self.frame.origin.x - self.speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect westFrame = CGRectMake(self.frame.origin.x  + self.speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect northFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.speed, self.frame.size.width, self.frame.size.height);
    CGRect southFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.speed, self.frame.size.width, self.frame.size.height);
    BOOL collidesEast = [self checkWallCollision:eastFrame];
    BOOL collidesWest = [self checkWallCollision:westFrame];
    BOOL collidesNorth = [self checkWallCollision:northFrame];
    BOOL collidesSouth = [self checkWallCollision:southFrame];
    
    NSMutableArray *possibleDirections = [NSMutableArray array];
    if (!collidesEast) [possibleDirections addObject:@{@"move":@('e'), @"frame":[NSValue valueWithCGRect:eastFrame]}];
    if (!collidesWest) [possibleDirections addObject:@{@"move":@('w'), @"frame":[NSValue valueWithCGRect:westFrame]}];
    if (!collidesNorth) [possibleDirections addObject:@{@"move":@('n'), @"frame":[NSValue valueWithCGRect:northFrame]}];
    if (!collidesSouth) [possibleDirections addObject:@{@"move":@('s'), @"frame":[NSValue valueWithCGRect:southFrame]}];
    switch ([self getBestDirection:possibleDirections targetFrame:nextFrame])
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
  [super update:deltaTime];
}

@end