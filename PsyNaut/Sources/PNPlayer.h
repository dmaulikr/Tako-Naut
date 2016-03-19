//
//  PNPlayer.h
//  Psynaut
//
//  Created by mugx on 17/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PLAYER_SPEED 1.5

@interface PNPlayer : UIImageView
- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction;
@property(nonatomic,assign) CGPoint velocity;
@property(nonatomic,assign) int wantedDirection_vertical;
@property(nonatomic,assign) int currentDirection_vertical;
@property(nonatomic,assign) int wantedDirection_horizontal;
@property(nonatomic,assign) int currentDirection_horizontal;
@end
