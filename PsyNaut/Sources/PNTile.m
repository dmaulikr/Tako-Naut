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
  NSArray *walls = [self.gameSession.wallsDictionary allValues];
  for (UIImageView *wall in walls)
  {
    if (!wall.hidden && CGRectIntersectsRect(wall.frame, frame))
    {
      return true;
    }
  }
  return false;
}

- (bool)collidesNorthOf:(CGRect)frame
{
  int col = (int)roundf(frame.origin.x / TILE_SIZE);
  int row = (int)roundf((frame.origin.y) / TILE_SIZE);
  if (row - 1 < 0) return YES;
  PNTile *tile = self.gameSession.wallsDictionary[[NSValue valueWithCGPoint:CGPointMake(row - 1, col)]];
  return tile != nil && !tile.hidden;
}

- (bool)collidesSouthOf:(CGRect)frame
{
  int col = (int)roundf(frame.origin.x / TILE_SIZE);
  int row = (int)roundf(frame.origin.y / TILE_SIZE);
  if (row + 1 >= self.gameSession.numRow) return YES;
  PNTile *tile = self.gameSession.wallsDictionary[[NSValue valueWithCGPoint:CGPointMake(row + 1, col)]];
  return tile != nil && !tile.hidden;
}

- (bool)collidesEastOf:(CGRect)frame
{
  int col = (int)roundf((frame.origin.x) / TILE_SIZE);
  int row = (int)roundf(frame.origin.y / TILE_SIZE);
  if (col - 1 < 0) return YES;
  PNTile *tile = self.gameSession.wallsDictionary[[NSValue valueWithCGPoint:CGPointMake(row, col - 1)]];
  return tile != nil && !tile.hidden;
}

- (bool)collidesWestOf:(CGRect)frame
{
  int col = (int)roundf(frame.origin.x / TILE_SIZE);
  int row = (int)roundf(frame.origin.y / TILE_SIZE);
  if (col + 1 >= self.gameSession.numCol) return YES;
  PNTile *tile = self.gameSession.wallsDictionary[[NSValue valueWithCGPoint:CGPointMake(row, col + 1)]];
  return tile != nil && !tile.hidden;
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
  if ((velx < 0 || velx > 0) && ![self checkWallCollision:frameOnHorizontalMove])
  {
    self.didHorizontalSwipe = false;
    didHorizontalMove = true;
    frame = frameOnHorizontalMove;
    
    if (vely != 0 && !self.didVerticalSwipe)
    {
      self.velocity = CGPointMake(self.velocity.x, 0);
    }
  }
  
  //--- checking vertical move ---//
  CGRect frameOnVerticalMove = CGRectMake(frame.origin.x, frame.origin.y + vely, frame.size.width, frame.size.height);
  if ((vely < 0 || vely > 0) && ![self checkWallCollision:frameOnVerticalMove])
  {
    self.didVerticalSwipe = false;
    didVerticalMove = true;
    frame = frameOnVerticalMove;
    
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
