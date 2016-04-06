//
//  PNTile.h
//  Psynaut
//
//  Created by mugx on 29/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNGameSession.h"

@interface PNTile : UIImageView
- (bool)checkWallCollision:(CGRect)frame;
- (MazeTyleType)getNorthOf:(CGRect)frame;
- (MazeTyleType)getSouthOf:(CGRect)frame;
- (MazeTyleType)getWestOf:(CGRect)frame;
- (MazeTyleType)getEastOf:(CGRect)frame;
- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction;
- (void)update:(CGFloat)updateTime;
@property(nonatomic,assign) CGPoint velocity;
@property(nonatomic,assign) float speed;
@property(nonatomic,assign) float padding;
@property(nonatomic,assign) bool didVerticalSwipe;
@property(nonatomic,assign) bool didHorizontalSwipe;
@property(nonatomic,weak) PNGameSession *gameSession;
@end
