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

- (void)snapToFloor_x
{
  PNPlayer *player = self.gameSession.player;
  int output_x = floorf(player.frame.origin.x / TILE_SIZE) * TILE_SIZE;
  player.frame = CGRectMake(output_x + 1, player.frame.origin.y, player.frame.size.width, player.frame.size.height);
}

- (void)snapToFloor_y
{
  PNPlayer *player = self.gameSession.player;
  int output_y = floorf(player.frame.origin.y / TILE_SIZE) * TILE_SIZE;
  player.frame = CGRectMake(player.frame.origin.x, output_y + 1, player.frame.size.width, player.frame.size.height);
}

- (void)update:(CGFloat)deltaTime
{
  PNPlayer *player = self.gameSession.player;
  CGRect frame = player.frame;
  float velx = player.velocity.x + player.velocity.x * deltaTime;
  float vely = player.velocity.y + player.velocity.y * deltaTime;
  bool moves_vertical = false;
  bool moves_horizontal = false;
  
  if (((velx < 0 && [self getEast] != MTWall) || (velx > 0 && [self getWest] != MTWall)) && ![self checkCollision:CGPointMake(velx, 0) frame:frame])
  {
    player.wantedDirection_horizontal = 0;
    int output_x1 = floorf(player.frame.origin.x / TILE_SIZE) * TILE_SIZE;
    frame = CGRectMake(frame.origin.x + velx, frame.origin.y, frame.size.width, frame.size.height);
    player.frame = frame;
    
    [UIView animateWithDuration:deltaTime animations:^{
      int output_x2 = floorf(player.frame.origin.x / TILE_SIZE) * TILE_SIZE;
      if (output_x1 != output_x2)
      {
        [self snapToFloor_y];
      }
    } completion:^(BOOL finished) {
    }];
    
    if (vely != 0 && !player.wantedDirection_vertical)
    {
      player.velocity = CGPointMake(player.velocity.x, 0);
    }
    player.wantedDirection_horizontal = 0;
    moves_horizontal = true;
  }
  
  if (((vely < 0 && [self getNorth] != MTWall) || (vely > 0 && [self getSouth] != MTWall)) && ![self checkCollision:CGPointMake(0, vely) frame:frame])
  {
    player.wantedDirection_vertical = 0;
    int output_y1 = floorf(player.frame.origin.y / TILE_SIZE) * TILE_SIZE;
    frame = CGRectMake(frame.origin.x, frame.origin.y + vely, frame.size.width, frame.size.height);
    player.frame = frame;
    [UIView animateWithDuration:deltaTime animations:^{
      int output_y2 = floorf(player.frame.origin.y / TILE_SIZE) * TILE_SIZE;
      if (output_y1 != output_y2)
      {
        [self snapToFloor_x];
      }
    } completion:^(BOOL finished) {
    }];
    
    player.wantedDirection_vertical = 0;
    moves_vertical = true;
    
    if (velx != 0 && !player.wantedDirection_horizontal)
    {
      player.velocity = CGPointMake(0, player.velocity.y);
    }
  }
  
  if (!moves_vertical && !moves_horizontal)
  {
    player.velocity = CGPointMake(0, 0);
  }
}

@end