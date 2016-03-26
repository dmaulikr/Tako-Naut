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

#define TILE_SIZE 32
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

@property(nonatomic,assign) MazeTyleType **maze;
@property(readonly) NSMutableArray<UIImageView *> *walls;
@property(readonly) UIView *mazeView;
@property(nonatomic,strong) PNCollisionCollaborator *collisionCollaborator;
@property(nonatomic,strong) PNEnemyCollaborator *enemyCollaborator;
@property(nonatomic,strong) PNPlayer *player;
@end

@protocol PNGameSessionDelegate <NSObject>
//- (void)didUpdate:(PNGameSession *)session;
//- (void)didHurryUp:(PNGameSession *)session;
//- (void)didLevelComplete:(PNGameSession *)session;
- (void)didUpdateScore:(NSUInteger)score;
- (void)didUpdateTime:(NSUInteger)time;
- (void)didGameOver:(PNGameSession *)session;
@end