//
//  TNGameSession.h
//  Takonaut
//
//  Created by mugx on 10/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TNCollisionCollaborator.h"
#import "TNEnemyCollaborator.h"

@class TNPlayer;
@class TNTile;

#define TILE_SIZE 32.0
#define STARTING CGPointMake(1,1)

@protocol TNGameSessionDelegate;

@interface TNGameSession : NSObject
- (instancetype)initWithView:(UIView *)gameView;
- (void)startLevel:(NSUInteger)levelNumber;
- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction;
- (void)update:(CGFloat)deltaTime;
@property(nonatomic,assign) id <TNGameSessionDelegate> delegate;

@property(readonly) NSUInteger currentLevel;
@property(readonly) NSUInteger currentScore;
@property(readonly) CGFloat currentTime;

@property(nonatomic,assign) NSUInteger numRow;
@property(nonatomic,assign) NSUInteger numCol;
@property(readonly) NSMutableDictionary<NSValue *, TNTile *> *wallsDictionary;
@property(readonly) UIView *mazeView;
@property(nonatomic,strong) TNCollisionCollaborator *collisionCollaborator;
@property(nonatomic,strong) TNEnemyCollaborator *enemyCollaborator;
@property(nonatomic,strong) TNPlayer *player;
@end

@protocol TNGameSessionDelegate <NSObject>
- (void)didUpdateScore:(NSUInteger)score;
- (void)didUpdateTime:(NSUInteger)time;
- (void)didGotMinion:(NSUInteger)minionCount;
- (void)didNextLevel:(NSUInteger)levelCount;
- (void)didGameOver:(TNGameSession *)session;
@end