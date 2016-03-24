//
//  PNEnemy.m
//  Psynaut
//
//  Created by mugx on 23/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNEnemy.h"

#define ANIM_TIME 0.5

@interface PNEnemy()
@property(nonatomic,weak) PNGameSession *gameSession;
@property(nonatomic,assign) BOOL isMoving;
@property(nonatomic,assign) CGPoint lastVel;
@end

@implementation PNEnemy

- (instancetype)initWithFrame:(CGRect)frame withGameSession:(PNGameSession *)gameSession
{
  self = [super initWithFrame:frame];
  _gameSession = gameSession;
  _isMoving = NO;
  _lastVel = CGPointMake(1, 1);
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
  //--- move randomly ---//
  //if (!self.isMoving)
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
    /*
    char moves[] = {'n', 's', 'e', 'w'};
    char move = moves[arc4random() % 4];
    
    switch (move) {
      case 'n':
        if ([self getNorth] != MTWall)
        {
          self.isMoving = YES;
          [UIView animateWithDuration:ANIM_TIME animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.frame.size.height, self.frame.size.width, self.frame.size.height);
          } completion:^(BOOL finished) {
            self.isMoving = NO;
          }];
        }
        break;
      case 's':
        if ([self getSouth] != MTWall)
        {
          self.isMoving = YES;
          [UIView animateWithDuration:ANIM_TIME animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
          } completion:^(BOOL finished) {
            self.isMoving = NO;
          }];
        }
        break;
      case 'e':
        if ([self getEast] != MTWall)
        {
          self.isMoving = YES;
          [UIView animateWithDuration:ANIM_TIME animations:^{
            self.frame = CGRectMake(self.frame.origin.x - self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
          } completion:^(BOOL finished) {
            self.isMoving = NO;
          }];
        }
        break;
      case 'w':
        if ([self getWest] != MTWall)
        {
          self.isMoving = YES;
          [UIView animateWithDuration:ANIM_TIME animations:^{
            self.frame = CGRectMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
          } completion:^(BOOL finished) {
            self.isMoving = NO;
          }];
        }
        break;
    }
     */
  }
}

@end