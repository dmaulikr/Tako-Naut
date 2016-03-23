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
  
  return false;
}

- (MazeTyleType)getNorth
{
  int x = (int)floorf(self.gameSession.player.frame.origin.x / TILE_SIZE);
  int y = (int)floorf((self.gameSession.player.frame.origin.y + self.gameSession.player.frame.size.height) / TILE_SIZE);
  return self.gameSession.maze[y - 1][x];
}

- (MazeTyleType)getSouth
{
  int x = (int)floorf(self.gameSession.player.frame.origin.x / TILE_SIZE);
  int y = (int)floorf(self.gameSession.player.frame.origin.y / TILE_SIZE);
  return self.gameSession.maze[y + 1][x];
}

- (MazeTyleType)getWest
{
  int x = (int)floorf(self.gameSession.player.frame.origin.x / TILE_SIZE);
  int y = (int)floorf(self.gameSession.player.frame.origin.y / TILE_SIZE);
  return self.gameSession.maze[y][x + 1];
}

- (MazeTyleType)getEast
{
  int x = (int)floorf((self.gameSession.player.frame.origin.x + self.gameSession.player.frame.size.width) / TILE_SIZE);
  int y = (int)floorf(self.gameSession.player.frame.origin.y / TILE_SIZE);
  return self.gameSession.maze[y][x - 1];
}

- (void)update:(CGFloat)deltaTime
{
  PNPlayer *player = self.gameSession.player;
  CGRect playerFrame = player.frame;
  float velx = player.velocity.x + player.velocity.x * deltaTime;
  float vely = player.velocity.y + player.velocity.y * deltaTime;
  bool didHorizontalMove = false;
  bool didVerticalMove = false;
  
  //--- checking horizontal move ---//
  CGRect frameOnHorizontalMove = CGRectMake(playerFrame.origin.x + velx, playerFrame.origin.y, playerFrame.size.width, playerFrame.size.height);
  if (((velx < 0 && [self getEast] != MTWall) || (velx > 0 && [self getWest] != MTWall)) && ![self checkCollision:frameOnHorizontalMove])
  {
    player.didHorizontalSwipe = false;
    didHorizontalMove = true;
    
    int oldx = floorf(playerFrame.origin.x / TILE_SIZE) * TILE_SIZE;
    playerFrame = frameOnHorizontalMove;
    int newx = floorf(playerFrame.origin.x / TILE_SIZE) * TILE_SIZE;
    
    if (oldx != newx) // if passed on new horizontal tile
    {
      // then snap on vertical
       playerFrame = CGRectMake(playerFrame.origin.x, (floorf(playerFrame.origin.y / TILE_SIZE) * TILE_SIZE) + PLAYER_PADDING, playerFrame.size.width, playerFrame.size.height);
    }
    
    if (vely != 0 && !player.didVerticalSwipe)
    {
      player.velocity = CGPointMake(player.velocity.x, 0);
    }
  }
  
  //--- checking vertical move ---//
  CGRect frameOnVerticalMove = CGRectMake(playerFrame.origin.x, playerFrame.origin.y + vely, playerFrame.size.width, playerFrame.size.height);
  if (((vely < 0 && [self getNorth] != MTWall) || (vely > 0 && [self getSouth] != MTWall)) && ![self checkCollision:frameOnVerticalMove])
  {
    player.didVerticalSwipe = false;
    didVerticalMove = true;
    
    int oldy = floorf(playerFrame.origin.y / TILE_SIZE) * TILE_SIZE;
    playerFrame = frameOnVerticalMove;
    int newy = floorf(playerFrame.origin.y / TILE_SIZE) * TILE_SIZE;
    
    if (oldy != newy) // if passed on new vertical tile
    {
      // then moving on horizontal snap
      //float destx = (floorf(playerFrame.origin.x / TILE_SIZE) * TILE_SIZE) + PLAYER_PADDING;
      //velx = destx - player.frame.origin.x;
      //velx = (velx > 0) && (velx > PLAYER_SPEED) ? PLAYER_SPEED : velx;
      //velx = (velx < 0) && (velx < PLAYER_SPEED) ? PLAYER_SPEED : velx;
      playerFrame = CGRectMake(floorf(playerFrame.origin.x / TILE_SIZE) * TILE_SIZE + PLAYER_PADDING, playerFrame.origin.y, playerFrame.size.width, playerFrame.size.height);
    }
    
    if (velx != 0 && !player.didHorizontalSwipe)
    {
      player.velocity = CGPointMake(0, player.velocity.y);
    }
  }

  if (didHorizontalMove || didVerticalMove)
  {
    player.frame = playerFrame;
  }
  else
  {
    player.velocity = CGPointMake(0, 0);
  }
}

@end