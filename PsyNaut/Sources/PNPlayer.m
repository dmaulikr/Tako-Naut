//
//  PNPlayer.m
//  Psynaut
//
//  Created by mugx on 17/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNPlayer.h"
#import "MXToolBox.h"
#import "PNGameSession.h"

@interface PNPlayer()
@end

@implementation PNPlayer

- (CGPoint)getNormalizedPosition
{
  CGPoint point;
  point.x = [self getNormalizedNumber:self.frame.origin.x];
  point.y = [self getNormalizedNumber:self.frame.origin.y];
  return point;
}

- (int)getNormalizedNumber:(float)number
{
  int output;
  int tile_size = TILE_SIZE;
  float temp = (float)number / (float)tile_size;
  
  int a,b;
  a = floorf(temp);
  b = ceilf(temp);
  bool bestA = fabs((tile_size * a) - number) < fabs((tile_size * b) - number);
  output = bestA ? tile_size * a : tile_size * b;
  return output;
}

- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction
{
  if (direction == UISwipeGestureRecognizerDirectionRight)
  {
    self.velocity = CGPointMake(PLAYER_SPEED, self.velocity.y);
    self.wantedDirection_horizontal = 1;
    MXLog(@"UISwipeGestureRecognizerDirectionRight");
  }
  
  if (direction == UISwipeGestureRecognizerDirectionLeft)
  {
    self.velocity = CGPointMake(-PLAYER_SPEED, self.velocity.y);
    self.wantedDirection_horizontal = 1;
    MXLog(@"UISwipeGestureRecognizerDirectionLeft");
  }
  
  if (direction == UISwipeGestureRecognizerDirectionUp)
  {
    self.velocity = CGPointMake(self.velocity.x, -PLAYER_SPEED);
    self.wantedDirection_vertical = 1;
    MXLog(@"UISwipeGestureRecognizerDirectionUp");
  }
  
  if (direction == UISwipeGestureRecognizerDirectionDown)
  {
    self.velocity = CGPointMake(self.velocity.x, PLAYER_SPEED);
    self.wantedDirection_vertical = 1;
    MXLog(@"UISwipeGestureRecognizerDirectionDown");
  }
}

@end
