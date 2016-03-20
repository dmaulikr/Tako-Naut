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

- (bool)checkCollision:(CGPoint)velocity
{
  PNPlayer *player = self.gameSession.player;
  NSArray *walls = self.gameSession.walls;
  CGRect playerFrame = CGRectMake(player.frame.origin.x + velocity.x, player.frame.origin.y + velocity.y, player.frame.size.width, player.frame.size.height);
  
  for (UIImageView *wall in walls)
  {
    if (CGRectIntersectsRect(wall.frame, playerFrame))
    {
      return true;
    }
  }
  return false;
}

- (void)update:(CGFloat)deltaTime
{
  PNPlayer *player = self.gameSession.player;
  float velx = player.velocity.x + player.velocity.x * deltaTime;
  bool collidesX = [self checkCollision:CGPointMake(velx, 0)];
  
  //--- walls horizontal collision detection ---//
  if (!collidesX && (player.wantedDirection_horizontal == 1 || player.currentDirection_horizontal == 1))
  {
    player.frame = CGRectMake(player.frame.origin.x + velx, player.frame.origin.y, player.frame.size.width, player.frame.size.height);
    player.wantedDirection_horizontal = 0;
    player.currentDirection_horizontal = 1;
  }
  else if (collidesX)
  {
    player.frame = CGRectMake([self getMagicNumber:player.frame.origin.x], player.frame.origin.y, player.frame.size.width, player.frame.size.height);
    player.currentDirection_horizontal = 0;
  }
  
  float vely = player.velocity.y + player.velocity.y * deltaTime;
  bool collidesY = [self checkCollision:CGPointMake(0, vely)];
  
  //--- walls vertical collision detection ---//
  if (!collidesY && (player.wantedDirection_vertical == 1 || player.currentDirection_vertical == 1))
  {
    player.frame = CGRectMake(player.frame.origin.x, player.frame.origin.y + vely, player.frame.size.width, player.frame.size.height);
    player.wantedDirection_vertical = 0;
    player.currentDirection_vertical = 1;
  }
  else if (collidesY)
  {
    player.frame = CGRectMake(player.frame.origin.x, [self getMagicNumber:player.frame.origin.y], player.frame.size.width, player.frame.size.height);
    player.currentDirection_vertical = 0;
  }
  
  if (collidesX && collidesY)
  {
    player.velocity = CGPointMake(0, 0);
    player.frame = CGRectMake([self getMagicNumber:player.frame.origin.x], [self getMagicNumber:player.frame.origin.y], player.frame.size.width, player.frame.size.height);
  }
}

@end
