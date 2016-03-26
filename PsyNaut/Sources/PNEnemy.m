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
    /*
    float manhattanEast = abs((player.frame.origin.x - (self.frame.origin.x - self.speed)) + (player.frame.origin.y - self.frame.origin.y));
    float manhattanWest = abs((player.frame.origin.x - (self.frame.origin.x + self.speed)) + (player.frame.origin.y - self.frame.origin.y));
    float manhattanNorth = abs((player.frame.origin.x - self.frame.origin.x) + (player.frame.origin.y - (self.frame.origin.y - self.speed)));
    float manhattanSouth = abs((player.frame.origin.x - self.frame.origin.x) + (player.frame.origin.y - (self.frame.origin.y + self.speed)));
     */
    float manhattanEast = abs((int)(eastFrame.origin.x - player.frame.origin.x)) + abs((int)(eastFrame.origin.y - player.frame.origin.y));
    float manhattanWest = abs((int)(westFrame.origin.x - player.frame.origin.x)) + abs((int)(westFrame.origin.y - player.frame.origin.y));
    float manhattanNorth = abs((int)(northFrame.origin.x - player.frame.origin.x)) + abs((int)(northFrame.origin.y - player.frame.origin.y));
    float manhattanSouth = abs((int)(southFrame.origin.x - player.frame.origin.x)) + abs((int)(southFrame.origin.y - player.frame.origin.y));
    
    BOOL collidesEast = [self checkEnemyCollision:eastFrame];
    BOOL collidesWest = [self checkEnemyCollision:westFrame];
    BOOL collidesNorth =  [self checkEnemyCollision:northFrame];
    BOOL collidesSouth =  [self checkEnemyCollision:southFrame];
    collidesEast = NO;
    collidesWest = NO;
    collidesNorth = NO;
    collidesSouth = NO;
    
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

/*
 //---- ALMOST not working Manhattan ---//
 - (BOOL)checkCollision:(CGRect)frame
 {
 for (PNEnemy *enemy in self.gameSession.enemyCollaborator.enemies)
 {
 int manhattanDistance = abs((int)(enemy.frame.origin.x - frame.origin.x)) + abs((int)(enemy.frame.origin.y - frame.origin.y));
 if (enemy != self && manhattanDistance > TILE_SIZE / 5)
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
 //--- manhattan distance ---//
 CGRect frame = self.frame;
 PNPlayer *player = [self.gameSession player];
 
 CGRect eastFrame = CGRectMake(self.frame.origin.x - self.speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
 CGRect westFrame = CGRectMake(self.frame.origin.x  + self.speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
 CGRect northFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.speed, self.frame.size.width, self.frame.size.height);
 CGRect southFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.speed, self.frame.size.width, self.frame.size.height);
 float manhattanEast = (player.frame.origin.x - (self.frame.origin.x - self.speed)) + (player.frame.origin.y - self.frame.origin.y);
 float manhattanWest = (player.frame.origin.x - (self.frame.origin.x + self.speed)) + (player.frame.origin.y - self.frame.origin.y);
 float manhattanNorth = (player.frame.origin.x - self.frame.origin.x) + (player.frame.origin.y - (self.frame.origin.y - self.speed));
 float manhattanSouth = (player.frame.origin.x - self.frame.origin.x) + (player.frame.origin.y - (self.frame.origin.y + self.speed));
 manhattanEast = manhattanEast > 0 ? manhattanEast : manhattanEast * -1;
 manhattanWest = manhattanWest > 0 ? manhattanWest : manhattanWest * -1;
 manhattanNorth = manhattanNorth > 0 ? manhattanNorth : manhattanNorth * -1;
 manhattanSouth = manhattanSouth > 0 ? manhattanSouth : manhattanSouth * -1;
 
 BOOL collidesEast = [self getEast] == MTWall || [self checkCollision:eastFrame];
 BOOL collidesWest = [self getWest] == MTWall || [self checkCollision:westFrame];
 BOOL collidesNorth = [self getNorth] == MTWall || [self checkCollision:northFrame];
 BOOL collidesSouth = [self getSouth] == MTWall || [self checkCollision:southFrame];
 
 if (manhattanEast <= manhattanWest && manhattanEast <= manhattanNorth && manhattanEast <= manhattanSouth && !collidesEast)
 {
 frame = eastFrame;
 }
 
 if (manhattanWest <= manhattanEast && manhattanWest <= manhattanNorth && manhattanWest <= manhattanSouth && !collidesWest)
 {
 frame = westFrame;
 }
 
 if (manhattanNorth <= manhattanWest && manhattanNorth <= manhattanEast && manhattanNorth <= manhattanSouth && !collidesNorth)
 {
 frame = northFrame;
 }
 
 if (manhattanSouth <= manhattanWest && manhattanSouth <= manhattanEast && manhattanSouth <= manhattanNorth && !collidesSouth)
 {
 frame = southFrame;
 }
 
 if (self.frame.origin.x == frame.origin.x && self.frame.origin.y == frame.origin.y)
 {
 if (!collidesEast) frame = eastFrame;
 if (!collidesWest) frame = westFrame;
 if (!collidesNorth) frame = northFrame;
 if (!collidesSouth) frame = southFrame;
 }
 
 self.frame = frame;
 }
 */

@end