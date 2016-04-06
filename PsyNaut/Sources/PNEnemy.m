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

@interface PNEnemy()
@property(nonatomic,strong) NSMutableArray *exploredTiles;
@end

@implementation PNEnemy

- (instancetype)initWithFrame:(CGRect)frame withGameSession:(PNGameSession *)gameSession
{
  self = [super initWithFrame:frame];
  _exploredTiles = [NSMutableArray array];
  
  self.gameSession = gameSession;
  self.speed = ENEMY_SPEED;
  self.padding = ENEMY_PADDING;
  self.velocity = CGPointMake(0, 0);
  return self;
}

- (void)exploreCurrentTile
{
  int x = (int)floorf(self.frame.origin.x / TILE_SIZE);
  int y = (int)floorf(self.frame.origin.y / TILE_SIZE);
  NSValue *currentTile = [NSValue valueWithCGPoint:CGPointMake(x, y)];
  if (![self.exploredTiles containsObject:currentTile])
  {
    [self.exploredTiles addObject:currentTile];
  }
}

/*
- (bool)checkCollision:(CGRect)frame
{
  BOOL collidesWall = [self checkWallCollision:frame];
  //BOOL collidesEnemy = NO;//[self checkEnemyCollision:frame];
  return collidesWall;
}

- (bool)checkEnemyCollision:(CGRect)frame
{
  for (PNEnemy *enemy in self.gameSession.enemyCollaborator.enemies)
  {
    int manhattanDistance = abs((int)(enemy.frame.origin.x - frame.origin.x)) + abs((int)(enemy.frame.origin.y - frame.origin.y));
    if (enemy != self && manhattanDistance > TILE_SIZE / 2)
    {
      if (enemy.tag == self.tag && CGRectIntersectsRect(enemy.frame, frame))
      {
        return true;
      }
    }
  }
  return false;
}
 */

- (void)searchPlayer
{
  bool playerFound = false;
  CGRect oldFrame = CGRectMake((int)floorf(self.frame.origin.x / TILE_SIZE) * TILE_SIZE, (int)floorf(self.frame.origin.y / TILE_SIZE) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
  CGRect currentFrame = CGRectMake((int)floorf(self.frame.origin.x / TILE_SIZE) * TILE_SIZE, (int)floorf(self.frame.origin.y / TILE_SIZE) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
  float currentSpeed = TILE_SIZE;
  float currentSize = TILE_SIZE;
  NSMutableArray *visited = [@[[NSValue valueWithCGRect:currentFrame]] mutableCopy];
  self.exploredTiles = [@[[NSValue valueWithCGRect:currentFrame]] mutableCopy];
  while (!playerFound)
  {
    PNPlayer *player = [self.gameSession player];
    if (CGRectIntersectsRect(player.frame, currentFrame))
    {
      playerFound = true;
      [visited removeObject:[NSValue valueWithCGRect:oldFrame]];
      self.exploredTiles = visited;
    }
    else
    {
      CGRect eastFrame = CGRectMake(currentFrame.origin.x - currentSpeed, currentFrame.origin.y, currentSize, currentSize);
      CGRect westFrame = CGRectMake(currentFrame.origin.x + currentSpeed, currentFrame.origin.y, currentSize, currentSize);
      CGRect northFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y - currentSpeed, currentSize, currentSize);
      CGRect southFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y + currentSpeed, currentSize, currentSize);
      BOOL collidesEast = [self getEastOf:currentFrame] == MTWall || [self.exploredTiles containsObject:[NSValue valueWithCGRect:eastFrame]];
      BOOL collidesWest = [self getWestOf:currentFrame] == MTWall || [self.exploredTiles containsObject:[NSValue valueWithCGRect:westFrame]];
      BOOL collidesNorth = [self getNorthOf:currentFrame] == MTWall || [self.exploredTiles containsObject:[NSValue valueWithCGRect:northFrame]];
      BOOL collidesSouth = [self getSouthOf:currentFrame] == MTWall || [self.exploredTiles containsObject:[NSValue valueWithCGRect:southFrame]];
      
      NSMutableArray *possibleDirections = [NSMutableArray array];
      if (!collidesEast) [possibleDirections addObject:@('e')];
      if (!collidesWest) [possibleDirections addObject:@('w')];
      if (!collidesSouth) [possibleDirections addObject:@('s')];
      if (!collidesNorth) [possibleDirections addObject:@('n')];
      
      if (possibleDirections.count > 0)
      {
        switch([possibleDirections[arc4random() % possibleDirections.count] charValue])
        {
          case 'n':
            currentFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y - currentSpeed, currentSize, currentSize);
            break;
          case 's':
            currentFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y + currentSpeed, currentSize, currentSize);
            break;
          case 'e':
            currentFrame = CGRectMake(currentFrame.origin.x - currentSpeed, currentFrame.origin.y, currentSize, currentSize);
            break;
          case 'w':
            currentFrame = CGRectMake(currentFrame.origin.x + currentSpeed, currentFrame.origin.y, currentSize, currentSize);
            break;
        }
        
        NSValue *currentTile = [NSValue valueWithCGRect:currentFrame];
        if (![self.exploredTiles containsObject:currentTile])
        {
          [self.exploredTiles addObject:currentTile];
          [visited addObject:currentTile];
        }
      }
      else
      {
        NSValue *currentTile = [visited lastObject];
        if (currentTile)
        {
          currentFrame = [currentTile CGRectValue];
          [visited removeLastObject];
        }
        else
        {
          NSLog(@"deadlock!");
          [self.exploredTiles removeAllObjects];
        }
      }
    }
  }
}

- (void)update:(CGFloat)deltaTime
{
  [self searchPlayer];
  if (self.exploredTiles.count > 0)
  {
    CGRect nextFrame = [self.exploredTiles.firstObject CGRectValue];
    CGRect eastFrame = CGRectMake(self.frame.origin.x - self.speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect westFrame = CGRectMake(self.frame.origin.x  + self.speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect northFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.speed, self.frame.size.width, self.frame.size.height);
    CGRect southFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.speed, self.frame.size.width, self.frame.size.height);
    
    float manhattanEast = fabs(eastFrame.origin.x - nextFrame.origin.x) + fabs(eastFrame.origin.y - nextFrame.origin.y);
    float manhattanWest = fabs(westFrame.origin.x - nextFrame.origin.x) + fabs(westFrame.origin.y - nextFrame.origin.y);
    float manhattanNorth = fabs(northFrame.origin.x - nextFrame.origin.x) + fabs(northFrame.origin.y - nextFrame.origin.y);
    float manhattanSouth = fabs(southFrame.origin.x - nextFrame.origin.x) + fabs(southFrame.origin.y - nextFrame.origin.y);
    
    if (manhattanEast <= manhattanWest && manhattanEast <= manhattanNorth && manhattanEast <= manhattanSouth)
    {
      [self didSwipe:UISwipeGestureRecognizerDirectionLeft];
    }
    
    if (manhattanWest <= manhattanEast && manhattanWest <= manhattanNorth && manhattanWest <= manhattanSouth)
    {
      [self didSwipe:UISwipeGestureRecognizerDirectionRight];
    }
    
    if (manhattanNorth <= manhattanSouth && manhattanNorth <= manhattanEast && manhattanNorth <= manhattanWest)
    {
      [self didSwipe:UISwipeGestureRecognizerDirectionUp];
    }
    
    if (manhattanSouth <= manhattanNorth && manhattanSouth <= manhattanEast && manhattanSouth <= manhattanWest)
    {
      [self didSwipe:UISwipeGestureRecognizerDirectionDown];
    }
  }
  
  [super update:deltaTime];
}

@end