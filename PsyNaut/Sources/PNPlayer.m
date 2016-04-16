//
//  PNself.m
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

- (instancetype)initWithFrame:(CGRect)frame withGameSession:(PNGameSession *)gameSession
{
  self = [super initWithFrame:frame];
  self.gameSession = gameSession;
  self.speed = PLAYER_SPEED;
  return self;
}

- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction
{
  [super didSwipe:direction];
}

- (void)update:(CGFloat)deltaTime
{
  [super update:deltaTime];
}

@end