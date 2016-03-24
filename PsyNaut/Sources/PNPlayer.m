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
@property(nonatomic,weak) PNGameSession *gameSession;
@end

@implementation PNPlayer

- (instancetype)initWithFrame:(CGRect)frame withGameSession:(PNGameSession *)gameSession
{
  self = [super initWithFrame:frame];
  _gameSession = gameSession;
  return self;
}

- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction
{
  if (direction == UISwipeGestureRecognizerDirectionRight)
  {
    self.velocity = CGPointMake(PLAYER_SPEED, self.velocity.y);
    self.didHorizontalSwipe = true;
    MXLog(@"UISwipeGestureRecognizerDirectionRight");
  }
  
  if (direction == UISwipeGestureRecognizerDirectionLeft)
  {
    self.velocity = CGPointMake(-PLAYER_SPEED, self.velocity.y);
    self.didHorizontalSwipe = true;
    MXLog(@"UISwipeGestureRecognizerDirectionLeft");
  }
  
  if (direction == UISwipeGestureRecognizerDirectionUp)
  {
    self.velocity = CGPointMake(self.velocity.x, -PLAYER_SPEED);
    self.didVerticalSwipe = true;
    MXLog(@"UISwipeGestureRecognizerDirectionUp");
  }
  
  if (direction == UISwipeGestureRecognizerDirectionDown)
  {
    self.velocity = CGPointMake(self.velocity.x, PLAYER_SPEED);
    self.didVerticalSwipe = true;
    MXLog(@"UISwipeGestureRecognizerDirectionDown");
  }
}

@end
