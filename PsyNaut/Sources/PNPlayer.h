//
//  PNPlayer.h
//  Psynaut
//
//  Created by mugx on 17/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTile.h"
#import "PNGameSession.h"

#define PLAYER_SPEED 3.0
#define PLAYER_PADDING 0.75

@interface PNPlayer : PNTile
- (instancetype)initWithFrame:(CGRect)frame withGameSession:(PNGameSession *)gameSession;
@end
