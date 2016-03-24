//
//  PNPlayer.h
//  Psynaut
//
//  Created by mugx on 17/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNGameSession.h"

#define PLAYER_SPEED 1.5
#define PLAYER_PADDING 0.75

@interface PNPlayer : UIImageView
- (instancetype)initWithFrame:(CGRect)frame withGameSession:(PNGameSession *)gameSession;
- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction;
@property(nonatomic,assign) CGPoint velocity;
@property(nonatomic,assign) bool didVerticalSwipe;
@property(nonatomic,assign) bool didHorizontalSwipe;
@end
