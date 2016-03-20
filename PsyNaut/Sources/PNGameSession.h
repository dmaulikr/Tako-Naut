//
//  PNGameSession.h
//  Psynaut
//
//  Created by mugx on 10/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNPlayer.h"
#import "PNMazeGenerator.h"

#define TILE_SIZE 32

@interface PNGameSession : NSObject
- (instancetype)initWithView:(UIView *)view;
- (void)update:(CGFloat)deltaTime;
@property(nonatomic,strong) PNPlayer *player;
@property(nonatomic,assign) MazeTyleType **maze;
@property(readonly) NSMutableArray<UIImageView *> *walls;
@end
