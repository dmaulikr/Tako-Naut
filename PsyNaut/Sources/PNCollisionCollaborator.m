//
//  PNCollisionCollaborator.m
//  Psynaut
//
//  Created by mugx on 18/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNCollisionCollaborator.h"
#import "PNPlayer.h"

@interface PNCollisionCollaborator()
@property(nonatomic,weak) PNGameSession *gameSession;
@end

@implementation PNCollisionCollaborator

- (instancetype)init:(PNGameSession *)gameSession
{
  self = [super init];
  _gameSession = gameSession;
  return self;
}

- (int)getMagicNumber:(float)input
{
  int output;
  int tile_size = TILE_SIZE;
  float temp = (float)input / (float)tile_size;
  
  int a,b;
  a = floorf(temp);
  b = ceilf(temp);
  bool bestA = fabs((tile_size * a) - input) < fabs((tile_size * b) - input);
  output = bestA ? tile_size * a : tile_size * b;
  return output;
}

- (bool)checkCollision:(CGPoint)velocity frame:(CGRect)frame
{
  NSArray *walls = self.gameSession.walls;
  CGRect playerFrame = CGRectMake(frame.origin.x + velocity.x, frame.origin.y + velocity.y, frame.size.width, frame.size.height);
  
  for (UIImageView *wall in walls)
  {
    if (CGRectIntersectsRect(wall.frame, playerFrame))
    {
      return true;
    }
  }
  
  return false;
}

- (int)snapToFloor:(float)number
{
  /*
   int output;
   int tile_size = TILE_SIZE;
   float temp = (float)number / (float)tile_size;
   
   int a,b;
   a = floorf(temp);
   b = ceilf(temp);
   bool bestA = fabs((tile_size * a) - number) < fabs((tile_size * b) - number);
   output = bestA ? tile_size * a : tile_size * b;
   return output / TILE_SIZE;
   */
  int output = floorf(number / TILE_SIZE);
  return output;
}

- (MazeTyleType)getNorth
{
  int x = [self snapToFloor:self.gameSession.player.frame.origin.x];
  int y = [self snapToFloor:self.gameSession.player.frame.origin.y + self.gameSession.player.frame.size.height];
  MazeTyleType tyleType = self.gameSession.maze[y - 1][x];
  return tyleType;
}

- (MazeTyleType)getSouth
{
  int x = [self snapToFloor:self.gameSession.player.frame.origin.x];
  int y = [self snapToFloor:self.gameSession.player.frame.origin.y];
  MazeTyleType tyleType = self.gameSession.maze[y + 1][x];
  return tyleType;
}

- (MazeTyleType)getWest
{
  int x = [self snapToFloor:self.gameSession.player.frame.origin.x];
  int y = [self snapToFloor:self.gameSession.player.frame.origin.y];
  MazeTyleType tyleType = self.gameSession.maze[y][x + 1];
  return tyleType;
}

- (MazeTyleType)getEast
{
  int x = [self snapToFloor:self.gameSession.player.frame.origin.x + self.gameSession.player.frame.size.width];
  int y = [self snapToFloor:self.gameSession.player.frame.origin.y];
  MazeTyleType tyleType = self.gameSession.maze[y][x - 1];
  return tyleType;
}

- (void)update:(CGFloat)deltaTime
{
  PNPlayer *player = self.gameSession.player;
  CGRect frame = player.frame;
  float velx = player.velocity.x + player.velocity.x * deltaTime;
  float vely = player.velocity.y + player.velocity.y * deltaTime;
  bool moves_vertical = false;
  bool moves_horizontal = false;
  
  if ([self getWest] != MTWall && velx > 0 && ![self checkCollision:CGPointMake(velx, 0) frame:player.frame])
  {
    frame = CGRectMake(frame.origin.x + velx, frame.origin.y, frame.size.width, frame.size.height);
    player.wantedDirection_horizontal = 0;
    moves_horizontal = true;
  }
  
  if ([self getEast] != MTWall && velx < 0 && ![self checkCollision:CGPointMake(velx, 0) frame:player.frame])
  {
    frame = CGRectMake(frame.origin.x + velx, frame.origin.y, frame.size.width, frame.size.height);
    player.wantedDirection_horizontal = 0;
    moves_horizontal = true;
  }
  
  if ([self getNorth] != MTWall && vely < 0 && ![self checkCollision:CGPointMake(0, vely) frame:player.frame])
  {
    frame = CGRectMake(frame.origin.x, frame.origin.y + vely, frame.size.width, frame.size.height);
    player.wantedDirection_vertical = 0;
    moves_vertical = true;
  }
  
  if ([self getSouth] != MTWall && vely > 0 && ![self checkCollision:CGPointMake(0, vely) frame:player.frame])
  {
    frame = CGRectMake(frame.origin.x, frame.origin.y + vely, frame.size.width, frame.size.height);
    player.wantedDirection_vertical = 0;
    moves_vertical = true;
  }
  
  player.currentDirection_horizontal = moves_horizontal ? 1 : 0;
  player.currentDirection_vertical = moves_vertical ? 1 : 0;
  
  if (!player.currentDirection_horizontal && !player.currentDirection_vertical)
  {
    player.velocity = CGPointMake(0, 0);
//    frame = CGRectMake([self getMagicNumber:frame.origin.x], [self getMagicNumber:frame.origin.y], frame.size.width, frame.size.height);
  }
  player.frame = frame;
}

@end