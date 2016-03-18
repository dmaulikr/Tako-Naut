//
//  PNPlayer.h
//  Psynaut
//
//  Created by mugx on 17/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PlayerDirection) {
  PDNone,
  PDNorth,
  PDSouth,
  PDEast,
  PDWest
};

#define PLAYER_SPEED 1.5

@interface PNPlayer : UIImageView
- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction;
@property(nonatomic,assign) CGPoint velocity;
@end
