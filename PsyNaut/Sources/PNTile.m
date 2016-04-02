//
//  PNTile.m
//  Psynaut
//
//  Created by mugx on 29/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNTile.h"
#import "MXToolBox/MXToolBox.h"

@interface PNTile()
@property(nonatomic,assign) BOOL facingNorth;
@property(nonatomic,assign) BOOL facingSouth;
@property(nonatomic,assign) BOOL facingEast;
@property(nonatomic,assign) BOOL facingWest;
@end

@implementation PNTile

- (bool)checkWallCollision:(CGRect)frame
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

- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction
{
  if (direction == UISwipeGestureRecognizerDirectionRight)
  {
    self.velocity = CGPointMake(self.speed, self.velocity.y);
    self.didHorizontalSwipe = true;
  }
  
  if (direction == UISwipeGestureRecognizerDirectionLeft)
  {
    self.velocity = CGPointMake(-self.speed, self.velocity.y);
    self.didHorizontalSwipe = true;
  }
  
  if (direction == UISwipeGestureRecognizerDirectionUp)
  {
    self.velocity = CGPointMake(self.velocity.x, -self.speed);
    self.didVerticalSwipe = true;
  }
  
  if (direction == UISwipeGestureRecognizerDirectionDown)
  {
    self.velocity = CGPointMake(self.velocity.x, self.speed);
    self.didVerticalSwipe = true;
  }
}

- (void)update:(CGFloat)deltaTime
{
  CGRect frame = self.frame;
  float velx = self.velocity.x + self.velocity.x * deltaTime;
  float vely = self.velocity.y + self.velocity.y * deltaTime;
  bool didHorizontalMove = false;
  bool didVerticalMove = false;
  
  //--- checking horizontal move ---//
  CGRect frameOnHorizontalMove = CGRectMake(frame.origin.x + velx, frame.origin.y, frame.size.width, frame.size.height);
  if (((velx < 0 && [self getEast] != MTWall) || (velx > 0 && [self getWest] != MTWall)) && ![self checkWallCollision:frameOnHorizontalMove])
  {
    self.didHorizontalSwipe = false;
    didHorizontalMove = true;
    
    int oldx = floorf(frame.origin.x / TILE_SIZE) * TILE_SIZE;
    frame = frameOnHorizontalMove;
    int newx = floorf(frame.origin.x / TILE_SIZE) * TILE_SIZE;
    
    if (oldx != newx) // if passed on new horizontal tile
    {
      // then snap on vertical
      frame = CGRectMake(frame.origin.x, (floorf(frame.origin.y / TILE_SIZE) * TILE_SIZE) + self.padding, frame.size.width, frame.size.height);
    }
    
    if (vely != 0 && !self.didVerticalSwipe)
    {
      self.velocity = CGPointMake(self.velocity.x, 0);
    }
  }
  
  //--- checking vertical move ---//
  CGRect frameOnVerticalMove = CGRectMake(frame.origin.x, frame.origin.y + vely, frame.size.width, frame.size.height);
  if (((vely < 0 && [self getNorth] != MTWall) || (vely > 0 && [self getSouth] != MTWall)) && ![self checkWallCollision:frameOnVerticalMove])
  {
    self.didVerticalSwipe = false;
    didVerticalMove = true;
    
    int oldy = floorf(frame.origin.y / TILE_SIZE) * TILE_SIZE;
    frame = frameOnVerticalMove;
    int newy = floorf(frame.origin.y / TILE_SIZE) * TILE_SIZE;
    
    if (oldy != newy) // if passed on new vertical tile
    {
      // then moving on horizontal snap
      frame = CGRectMake(floorf(frame.origin.x / TILE_SIZE) * TILE_SIZE + self.padding, frame.origin.y, frame.size.width, frame.size.height);
    }
    
    if (velx != 0 && !self.didHorizontalSwipe)
    {
      self.velocity = CGPointMake(0, self.velocity.y);
    }
  }
  
  if (didHorizontalMove || didVerticalMove)
  {
    self.frame = frame;
  }
  else
  {
    self.velocity = CGPointMake(0, 0);
    self.speed = self.speed;
  }
  
  //--- rotate towards ---//
  if (self.velocity.x > 0 && didHorizontalMove && !self.facingWest)
  {
    self.facingNorth = NO;
    self.facingSouth = NO;
    self.facingWest = YES;
    self.facingEast = NO;
    [UIView animateWithDuration:0.1 animations:^{
      self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
    }];
  }
  
  if (self.velocity.x < 0 && didHorizontalMove && !self.facingEast)
  {
    self.facingNorth = NO;
    self.facingSouth = NO;
    self.facingWest = NO;
    self.facingEast = YES;
    [UIView animateWithDuration:0.1 animations:^{
      self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
    }];
  }
  
  if (self.velocity.y < 0 && didVerticalMove && !self.facingNorth)
  {
    self.facingNorth = YES;
    self.facingSouth = NO;
    self.facingWest = NO;
    self.facingEast = NO;
    [UIView animateWithDuration:0.1 animations:^{
      self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
    }];
  }
  
  if (self.velocity.y > 0 && didVerticalMove && !self.facingSouth)
  {
    self.facingNorth = NO;
    self.facingSouth = YES;
    self.facingWest = NO;
    self.facingEast = NO;
    [UIView animateWithDuration:0.1 animations:^{
      self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
    }];
  }
}

@end
