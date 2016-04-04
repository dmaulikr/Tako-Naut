//
//  PNEnemy.m
//  Psynaut
//
//  Created by mugx on 23/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNEnemy.h"
#import "PNPlayer.h"

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
  self.velocity = CGPointMake(self.speed, self.speed);
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

- (bool)checkCollision:(CGRect)frame
{
  BOOL collidesWall = [self checkWallCollision:frame];
  BOOL collidesEnemy = [self checkEnemyCollision:frame];
  BOOL collidesExploredTiles = [self checkExploredTilesCollision:frame];
  return collidesWall || collidesEnemy || collidesExploredTiles;
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

- (bool)checkExploredTilesCollision:(CGRect)frame
{
  int currentX = (int)floorf(self.frame.origin.x / TILE_SIZE);
  int currentY = (int)floorf(self.frame.origin.y / TILE_SIZE);
  
  int x = (int)floorf(frame.origin.x / TILE_SIZE);
  int y = (int)floorf(frame.origin.y / TILE_SIZE);
  
  if (currentX != x || currentY != y)
  {
    for (NSValue *value in self.exploredTiles)
    {
      CGPoint currentTile = [value CGPointValue];
      if (x == currentTile.x && y == currentTile.y)
      {
        return true;
      }
    }
  }
  return false;
}

- (void)doSwipe
{
  CGPoint vel = self.velocity;
  if ([self checkEnemyCollision:CGRectMake(self.frame.origin.x + vel.x, self.frame.origin.y + vel.y, self.frame.size.width, self.frame.size.height)])
  {
    self.speed = ENEMY_SPEED * 2;
    self.padding = ENEMY_PADDING * 2;
  }
  else if ((vel.x == 0 && vel.y == 0) || [self checkExploredTilesCollision:CGRectMake(self.frame.origin.x + vel.x, self.frame.origin.y + vel.y, self.frame.size.width, self.frame.size.height)])
  {
    self.speed = ENEMY_SPEED;
    self.padding = ENEMY_PADDING;
    PNPlayer *player = [self.gameSession player];
    
    CGRect eastFrame = CGRectMake(self.frame.origin.x - self.speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect westFrame = CGRectMake(self.frame.origin.x  + self.speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect northFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.speed, self.frame.size.width, self.frame.size.height);
    CGRect southFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.speed, self.frame.size.width, self.frame.size.height);
    BOOL collidesEast = [self checkCollision:eastFrame];
    BOOL collidesWest = [self checkCollision:westFrame];
    BOOL collidesNorth = [self checkCollision:northFrame];
    BOOL collidesSouth = [self checkCollision:southFrame];
    
    float manhattanEast = fabs(eastFrame.origin.x - player.frame.origin.x) + fabs(eastFrame.origin.y - player.frame.origin.y);
    float manhattanWest = fabs(westFrame.origin.x - player.frame.origin.x) + fabs(westFrame.origin.y - player.frame.origin.y);
    float manhattanNorth = fabs(northFrame.origin.x - player.frame.origin.x) + fabs(northFrame.origin.y - player.frame.origin.y);
    float manhattanSouth = fabs(southFrame.origin.x - player.frame.origin.x) + fabs(southFrame.origin.y - player.frame.origin.y);
    
    vel = CGPointZero;
    bool doRandomMovement = false;
    if (manhattanEast < manhattanWest && !collidesEast)
    {
      vel.x = -self.speed;
    }
    
    if (manhattanEast > manhattanWest && !collidesWest)
    {
      vel.x = +self.speed;
    }
    
    if (manhattanNorth < manhattanSouth && !collidesNorth)
    {
      vel.y = -self.speed;
    }
    
    if (manhattanNorth > manhattanSouth && !collidesSouth)
    {
      vel.y = +self.speed;
    }
    
    if ((vel.x == 0 && vel.y == 0) || doRandomMovement)
    {
      double spinx = arc4random() % 2 == 0 ? 1 : -1;
      double spiny = arc4random() % 2 == 0 ? 1 : -1;
      vel = CGPointMake(spinx * (arc4random() % 2), spiny * (arc4random() % 2));
      
      if ([self checkCollision:CGRectMake(self.frame.origin.x + vel.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)])
      {
        vel.x = 0;
      }
      
      if ([self checkCollision:CGRectMake(self.frame.origin.x, self.frame.origin.y + vel.y, self.frame.size.width, self.frame.size.height)])
      {
        vel.y = 0;
      }
      [self.exploredTiles removeAllObjects];
    }
    self.wantSpawn = YES;
  }
  
  if (vel.x > 0)
  {
    [self didSwipe:UISwipeGestureRecognizerDirectionRight];
  }
  else if (vel.x < 0)
  {
    [self didSwipe:UISwipeGestureRecognizerDirectionLeft];
  }
  
  if (vel.y > 0)
  {
    [self didSwipe:UISwipeGestureRecognizerDirectionDown];
  }
  else if (vel.y < 0)
  {
    [self didSwipe:UISwipeGestureRecognizerDirectionUp];
  }
}

- (void)update:(CGFloat)deltaTime
{
  [self doSwipe];
  [super update:deltaTime];
  [self exploreCurrentTile];
}

@end