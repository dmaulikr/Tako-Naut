//
//  TNTile.h
//  Takonaut
//
//  Created by mugx on 29/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TNGameSession.h"

typedef NS_ENUM(NSUInteger, TyleType) {
  TTDoor,
  TTWall,
  TTExplodedWall,
  TTCoin,
  TTWhirlwind,
  TTBomb,
  TTTime,
  TTMinion,
  TTKey,
  TTMazeEnd_close,
  TTMazeEnd_open
};

@interface TNTile : UIImageView
- (TNTile *)checkWallCollision:(CGRect)frame;
- (bool)collidesNorthOf:(CGRect)frame;
- (bool)collidesSouthOf:(CGRect)frame;
- (bool)collidesWestOf:(CGRect)frame;
- (bool)collidesEastOf:(CGRect)frame;
- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction;
- (void)update:(CGFloat)updateTime;
@property(nonatomic,assign) CGPoint velocity;
@property(nonatomic,assign) float speed;
@property(nonatomic,assign) bool didVerticalSwipe;
@property(nonatomic,assign) bool didHorizontalSwipe;
@property(nonatomic,assign) int x;
@property(nonatomic,assign) int y;
@property(nonatomic,assign) BOOL isDestroyable;
@property(nonatomic,assign) BOOL isBlinking;
@property(nonatomic,assign) BOOL isAngry;
@property(nonatomic,weak) TNGameSession *gameSession;
@end
