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
@property(nonatomic,weak) PNGameSession *gameSession;
@property(nonatomic,assign) CGPoint lastVel;
@end

@implementation PNEnemy

- (instancetype)initWithFrame:(CGRect)frame withGameSession:(PNGameSession *)gameSession
{
  self = [super initWithFrame:frame];
  _gameSession = gameSession;
  _lastVel = CGPointMake(self.speed, self.speed);
  return self;
}

- (MazeTyleType)getNorth
{
  int x = (int)floorf(self.frame.origin.x / TILE_SIZE);
  int y = (int)floorf((self.frame.origin.y + self.frame.size.height) / TILE_SIZE);
  return self.gameSession.maze[y - 1][x];
}

- (MazeTyleType)getSouth
{
  int x = (int)floorf(self.frame.origin.x / TILE_SIZE);
  int y = (int)floorf(self.frame.origin.y / TILE_SIZE);
  return self.gameSession.maze[y + 1][x];
}

- (MazeTyleType)getWest
{
  int x = (int)floorf(self.frame.origin.x / TILE_SIZE);
  int y = (int)floorf(self.frame.origin.y / TILE_SIZE);
  return self.gameSession.maze[y][x + 1];
}

- (MazeTyleType)getEast
{
  int x = (int)floorf((self.frame.origin.x + self.frame.size.width) / TILE_SIZE);
  int y = (int)floorf(self.frame.origin.y / TILE_SIZE);
  return self.gameSession.maze[y][x - 1];
}

- (bool)checkCollision:(CGRect)frame
{
  NSArray *walls = self.gameSession.walls;
  for (UIImageView *wall in walls)
  {
    if (CGRectIntersectsRect(wall.frame, frame))
    {
      return true;
    }
  }
  return [self checkEnemyCollision:frame];
}

- (bool)checkEnemyCollision:(CGRect)frame
{
  for (PNEnemy *enemy in self.gameSession.enemyCollaborator.enemies)
  {
    int manhattanDistance = abs((int)(enemy.frame.origin.x - frame.origin.x)) + abs((int)(enemy.frame.origin.y - frame.origin.y));
    if (enemy != self && manhattanDistance > TILE_SIZE / 2)
    {
      if (CGRectIntersectsRect(enemy.frame, frame))
      {
        return true;
      }
    }
  }
  return false;
}

- (void)update:(CGFloat)deltaTime
{
  if (self.tag == 0) //--- move randomly ---//
  {
    CGPoint vel = self.lastVel;
    CGRect frame = CGRectMake(self.frame.origin.x + vel.x, self.frame.origin.y + vel.y, self.frame.size.width, self.frame.size.height);
    if ([self checkCollision:frame])
    {
      double spinx = arc4random() % 2 == 0 ? 1 : -1;
      double spiny = arc4random() % 2 == 0 ? 1 : -1;
      self.lastVel = CGPointMake(spinx * (arc4random() % 2), spiny * (arc4random() % 2));
    }
    else
    {
      self.frame = frame;
      
      if (vel.x == 0 && vel.y == 0)
      {
        double spinx = arc4random() % 2 == 0 ? 1 : -1;
        double spiny = arc4random() % 2 == 0 ? 1 : -1;
        self.lastVel = CGPointMake(spinx * (arc4random() % 2), spiny * (arc4random() % 2));
      }
    }
  }
  else //--- move manhattan ---//
  {
    //--- manhattan distance ---//
    CGRect frame = self.frame;
    PNPlayer *player = [self.gameSession player];
    
    CGRect eastFrame = CGRectMake(self.frame.origin.x - self.speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect westFrame = CGRectMake(self.frame.origin.x  + self.speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect northFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.speed, self.frame.size.width, self.frame.size.height);
    CGRect southFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.speed, self.frame.size.width, self.frame.size.height);
    
    float manhattanEast = fabs(eastFrame.origin.x - player.frame.origin.x) + fabs(eastFrame.origin.y - player.frame.origin.y);
    float manhattanWest = fabs(westFrame.origin.x - player.frame.origin.x) + fabs(westFrame.origin.y - player.frame.origin.y);
    float manhattanNorth = fabs(northFrame.origin.x - player.frame.origin.x) + fabs(northFrame.origin.y - player.frame.origin.y);
    float manhattanSouth = fabs(southFrame.origin.x - player.frame.origin.x) + fabs(southFrame.origin.y - player.frame.origin.y);
    
    CGPoint vel = CGPointZero;
    if (manhattanEast < manhattanWest)
    {
      vel.x = -self.speed;
    }
    else
    {
      vel.x = +self.speed;
    }
    
    if (manhattanNorth < manhattanSouth)
    {
      vel.y = -self.speed;
    }
    else
    {
      vel.y = +self.speed;
    }
    
    frame = CGRectMake(self.frame.origin.x + vel.x, self.frame.origin.y + vel.y, self.frame.size.width, self.frame.size.height);
    self.frame = frame;
  }
}

@end