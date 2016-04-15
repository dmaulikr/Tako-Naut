//
//  PNGameSession.h
//  Psynaut
//
//  Created by mugx on 10/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PNMazeGenerator.h"
#import "PNCollisionCollaborator.h"
#import "PNEnemyCollaborator.h"

@class PNPlayer;
@class PNTile;

#define TILE_SIZE 32.0
#define STARTING CGPointMake(1,1)

@protocol PNGameSessionDelegate;

@interface PNGameSession : NSObject
- (instancetype)initWithView:(UIView *)gameView;
- (void)startLevel:(NSUInteger)levelNumber;
- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction;
- (void)update:(CGFloat)deltaTime;
@property(nonatomic,assign) id <PNGameSessionDelegate> delegate;

@property(readonly) NSUInteger currentLevel;
@property(readonly) NSUInteger currentScore;
@property(readonly) CGFloat currentTime;

@property(nonatomic,assign) NSUInteger numRow;
@property(nonatomic,assign) NSUInteger numCol;
@property(readonly) NSMutableDictionary<NSValue *, PNTile *> *wallsDictionary;
@property(readonly) UIView *mazeView;
@property(nonatomic,strong) PNCollisionCollaborator *collisionCollaborator;
@property(nonatomic,strong) PNEnemyCollaborator *enemyCollaborator;
@property(nonatomic,strong) PNPlayer *player;
@end

@protocol PNGameSessionDelegate <NSObject>
- (void)didUpdateScore:(NSUInteger)score;
- (void)didUpdateTime:(NSUInteger)time;
- (void)didGotMinion:(NSUInteger)minionCount;
- (void)didNextLevel:(NSUInteger)levelCount;
- (void)didGameOver:(PNGameSession *)session;
@end