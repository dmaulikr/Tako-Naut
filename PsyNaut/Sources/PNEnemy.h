//
//  PNEnemy.h
//  Psynaut
//
//  Created by mugx on 23/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNGameSession.h"
#import "PNTile.h"

#define ENEMY_SPEED 2.0
#define ENEMY_PADDING 0.75

@interface PNEnemy : PNTile
- (instancetype)initWithFrame:(CGRect)frame withGameSession:(PNGameSession *)gameSession;
- (void)update:(CGFloat)deltaTime;
@property(nonatomic,assign) BOOL wantSpawn;
@end
