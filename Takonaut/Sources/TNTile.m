//
//  TNTile.m
//  Takonaut
//
//  Created by mugx on 29/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "TNTile.h"
#import "MXToolBox/MXToolBox.h"

typedef enum : NSUInteger {
  FTNorth,
  FTSouth,
  FTEast,
  FTWest
} FacingType;

@interface TNTile()
@property(nonatomic,assign) int lastSwipe;
@property(nonatomic,assign) FacingType lastFacing;
@end

@implementation TNTile

- (TNTile *)checkWallCollision:(CGRect)frame
{
  NSArray *walls = [self.gameSession.wallsDictionary allValues];
  for (TNTile *wall in walls)
  {
    if (wall.tag != TTExplodedWall && CGRectIntersectsRect(wall.frame, frame))
    {
      return wall;
    }
  }
  return nil;
}

- (CGRect)wallCollision:(CGRect)frame
{
  NSArray *walls = [self.gameSession.wallsDictionary allValues];
  for (UIImageView *wall in walls)
  {
    if (wall.tag != TTExplodedWall && CGRectIntersectsRect(wall.frame, frame))
    {
      return CGRectIntersection(wall.frame, frame);
    }
  }
  return CGRectZero;
}

- (bool)collidesNorthOf:(CGRect)frame
{
  int col = (int)roundf(frame.origin.x / TILE_SIZE);
  int row = (int)roundf((frame.origin.y) / TILE_SIZE);
  if (row - 1 < 0) return YES;
  TNTile *tile = self.gameSession.wallsDictionary[[NSValue valueWithCGPoint:CGPointMake(row - 1, col)]];
  return tile != nil && tile.tag != TTExplodedWall;
}

- (bool)collidesSouthOf:(CGRect)frame
{
  int col = (int)roundf(frame.origin.x / TILE_SIZE);
  int row = (int)roundf(frame.origin.y / TILE_SIZE);
  if (row + 1 >= self.gameSession.numRow) return YES;
  TNTile *tile = self.gameSession.wallsDictionary[[NSValue valueWithCGPoint:CGPointMake(row + 1, col)]];
  return tile != nil && tile.tag != TTExplodedWall;
}

- (bool)collidesEastOf:(CGRect)frame
{
  int col = (int)roundf((frame.origin.x) / TILE_SIZE);
  int row = (int)roundf(frame.origin.y / TILE_SIZE);
  if (col - 1 < 0) return YES;
  TNTile *tile = self.gameSession.wallsDictionary[[NSValue valueWithCGPoint:CGPointMake(row, col - 1)]];
  return tile != nil && tile.tag != TTExplodedWall;
}

- (bool)collidesWestOf:(CGRect)frame
{
  int col = (int)roundf(frame.origin.x / TILE_SIZE);
  int row = (int)roundf(frame.origin.y / TILE_SIZE);
  if (col + 1 >= self.gameSession.numCol) return YES;
  TNTile *tile = self.gameSession.wallsDictionary[[NSValue valueWithCGPoint:CGPointMake(row, col + 1)]];
  return tile != nil && tile.tag != TTExplodedWall;
}

- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction
{
  self.lastSwipe = direction;
  
  if (self.lastSwipe == UISwipeGestureRecognizerDirectionRight)
  {
    self.velocity = CGPointMake(self.speed, self.velocity.y);
  }
  else if (self.lastSwipe == UISwipeGestureRecognizerDirectionLeft)
  {
    self.velocity = CGPointMake(-self.speed, self.velocity.y);
  }
  else if (self.lastSwipe == UISwipeGestureRecognizerDirectionUp)
  {
    self.velocity = CGPointMake(self.velocity.x, -self.speed);
  }
  else if (self.lastSwipe == UISwipeGestureRecognizerDirectionDown)
  {
    self.velocity = CGPointMake(self.velocity.x, self.speed);
  }
}

- (void)update:(CGFloat)deltaTime
{
  CGRect frame = self.frame;
  float velx = self.velocity.x + self.velocity.x * deltaTime;
  float vely = self.velocity.y + self.velocity.y * deltaTime;
  bool didHorizontalMove = false;
  bool didVerticalMove = false;
  bool didExplosion = false;
  
  //--- checking horizontal move ---//
  CGRect frameOnHorizontalMove = CGRectMake(frame.origin.x + velx, frame.origin.y, frame.size.width, frame.size.height);
  if (velx < 0 || velx > 0)
  {
    TNTile *collidedWall = [self checkWallCollision:frameOnHorizontalMove];
    if (!collidedWall)
    {
      didHorizontalMove = true;
      frame = frameOnHorizontalMove;
      
      if (vely != 0 && !(self.lastSwipe == UISwipeGestureRecognizerDirectionUp || self.lastSwipe == UISwipeGestureRecognizerDirectionDown))
      {
        self.velocity = CGPointMake(self.velocity.x, 0);
      }
    }
    
    if (collidedWall && self.isAngry && collidedWall.tag == TTWall && collidedWall.isDestroyable)
    {
      [collidedWall explode:nil];
      collidedWall.tag = TTExplodedWall;
      [self setIsAngry:NO];
      didExplosion = YES;
    }
  }
  
  //--- checking vertical move ---//
  CGRect frameOnVerticalMove = CGRectMake(frame.origin.x, frame.origin.y + vely, frame.size.width, frame.size.height);
  if (vely < 0 || vely > 0)
  {
    TNTile *collidedWall = [self checkWallCollision:frameOnVerticalMove];
    if (!collidedWall)
    {
      didVerticalMove = true;
      frame = frameOnVerticalMove;
      
      if (velx != 0 && !(self.lastSwipe == UISwipeGestureRecognizerDirectionLeft || self.lastSwipe == UISwipeGestureRecognizerDirectionRight))
      {
        self.velocity = CGPointMake(0, self.velocity.y);
      }
    }
    
    if (collidedWall && self.isAngry && collidedWall.tag == TTWall && collidedWall.isDestroyable)
    {
      [collidedWall explode:nil];
      collidedWall.tag = TTExplodedWall;
      [self setIsAngry:NO];
      didExplosion = YES;
    }
  }
  
  if (didHorizontalMove || didVerticalMove || didExplosion)
  {
    self.frame = frame;
  }
  else
  {
    self.velocity = CGPointMake(0, 0);
    self.speed = self.speed;
  }
  
  //--- rotate towards ---//
  if (didHorizontalMove && (self.lastFacing != FTWest || self.lastFacing != FTEast))
  {
    self.lastFacing = self.velocity.x > 0 ? FTWest : FTEast;
    [UIView animateWithDuration:0.1 animations:^{
      self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2 * (self.lastFacing == FTWest ? 1 : -1));
    }];
  }
  else if (didVerticalMove && (self.lastFacing != FTNorth || self.lastFacing != FTSouth))
  {
    self.lastFacing = self.velocity.y > 0 ? FTSouth : FTNorth;
    [UIView animateWithDuration:0.1 animations:^{
      self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * (self.lastFacing == FTNorth ? 0 : 1));
    }];
  }
}

@end
