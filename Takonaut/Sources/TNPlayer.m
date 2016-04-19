//
//  TNself.m
//  Takonaut
//
//  Created by mugx on 17/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "TNPlayer.h"
#import "MXToolBox.h"
#import "TNGameSession.h"

@interface TNPlayer()
@end

@implementation TNPlayer

- (instancetype)initWithFrame:(CGRect)frame withGameSession:(TNGameSession *)gameSession
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