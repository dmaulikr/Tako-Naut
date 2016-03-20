//
//  PNGameSession.m
//  Psynaut
//
//  Created by mugx on 10/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNGameSession.h"
#import "PNCollisionCollaborator.h"
#import "PNItem.h"
#import "PNMazeGenerator.h"
#import "MXToolBox.h"
#import "PNConstants.h"
#import "PNMacros.h"
#import <MXAudioManager/MXAudioManager.h>

#define STARTING CGPointMake(1,1)

@interface PNGameSession ()
@property(nonatomic,assign,readwrite) NSUInteger currentLevel;
@property(nonatomic,assign,readwrite) NSUInteger currentScore;
@property(nonatomic,assign,readwrite) CGFloat currentTime;
@property(nonatomic,strong,readwrite) NSMutableArray<UIImageView *> *walls;
@property(nonatomic,strong) NSMutableArray<PNItem *> *items;
@property(nonatomic,strong) PNCollisionCollaborator *collisionCollaborator;

@property(nonatomic,strong) PNMazeGenerator *mazeGenerator;
@property(nonatomic,assign) NSUInteger tileWidth;
@property(nonatomic,assign) NSUInteger tileHeight;
@property(nonatomic,assign) NSUInteger numRow;
@property(nonatomic,assign) NSUInteger numCol;

@property(nonatomic,strong) UIView *mazeView;
@property(nonatomic,weak) UIView *gameView;
@end

@implementation PNGameSession

- (void)dealloc
{
  free(_maze);
}

- (instancetype)initWithView:(UIView *)view
{
  self = [super init];
  _gameView = view;
  _currentScore = 0;
  _currentLevel = 1;
  _collisionCollaborator = [[PNCollisionCollaborator alloc] init:self];
  _walls = [NSMutableArray array];
  _items = [NSMutableArray array];
  _player = [PNPlayer new];
  
  self.walls = [NSMutableArray array];
  
  //--- setup maze ---//
  self.tileWidth = TILE_SIZE;
  self.tileHeight = TILE_SIZE;
  self.numCol = 15;
  self.numRow = 15;
  
  [self initMaze];
  [self initPlayer];
  [self initItems];
  
  return self;
}

- (void)initMaze
{
  self.mazeView = [[UIView alloc] initWithFrame:self.gameView.frame];
  [self.gameView addSubview:self.mazeView];
  [self.gameView sendSubviewToBack:self.mazeView];
  
  //--- generating the maze ---//
  PNMazeGenerator *mazeGenerator = [PNMazeGenerator new];
  self.maze = [mazeGenerator calculateMaze:self.numRow col:self.numCol startingPosition:STARTING];
  for (int r = 0; r < self.numRow ; r++)
  {
    for (int c = 0; c < self.numCol; c++)
    {
      if (self.maze[r][c] == MTWall)
      {
        UIImageView *wall = [[UIImageView alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
        [wall setImage:[[UIImage imageNamed:@"wall"] imageColored:BLUE_COLOR]];
        [self.mazeView addSubview:wall];
        [self.walls addObject:wall];
        [self.mazeView sendSubviewToBack:wall];
      }
      else if (self.maze[r][c] == MTStart)
      {
        UIImageView *wall = [[UIImageView alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
        wall.backgroundColor = [UIColor whiteColor];
        [self.mazeView addSubview:wall];
        [self.mazeView sendSubviewToBack:wall];
      }
      else if (self.maze[r][c] == MTEnd)
      {
        UIImageView *wall = [[UIImageView alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
        wall.backgroundColor = GREEN_COLOR;
        [self.mazeView addSubview:wall];
        [self.mazeView sendSubviewToBack:wall];
      }
    }
  }
}

- (void)initPlayer
{
  self.player = [[PNPlayer alloc] initWithFrame:CGRectMake(STARTING.y * self.tileWidth, STARTING.x * self.tileHeight, self.tileWidth - PLAYER_SPEED, self.tileHeight - PLAYER_SPEED)];
  self.player.animationImages = [[UIImage imageNamed:@"oct"] spritesWiteSize:CGSizeMake(self.tileWidth, self.tileHeight)];
  self.player.animationDuration = 0.4f;
  self.player.animationRepeatCount = 0;
  [self.player startAnimating];
  [self.mazeView addSubview:self.player];
  [self.mazeView bringSubviewToFront:self.player];
}

- (void)initItems
{
  for (int r = 0; r < self.numRow ; r++)
  {
    for (int c = 0; c < self.numCol; c++)
    {
      if (self.self.maze[r][c] == MTPath)
      {
        if ((arc4random() % 100) >= 80)
        {
          PNItem *coin = [[PNItem alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
          coin.image = [[UIImage imageNamed:@"coin"] imageColored:[UIColor yellowColor]];
          [self.mazeView addSubview:coin];
          [self.mazeView sendSubviewToBack:coin];
          [self.items addObject:coin];
        }
      }
    }
  }
}

- (void)update:(CGFloat)deltaTime
{
  //--- checking walls collisions ---//
  [self.collisionCollaborator update:deltaTime];
  
  //--- checking items collisions ---//
  NSMutableArray *array = [NSMutableArray array];
  for (PNItem *item in self.items)
  {
    if (CGRectIntersectsRect(item.frame, self.player.frame))
    {
      [[MXAudioManager sharedInstance] play:STGoodHit];
      item.hidden = true;
      [array addObject:item];
      continue;
    }
  }
  [self.items removeObjectsInArray:array];
  
  //--- updating maze frame ---//
  self.mazeView.frame = CGRectMake(self.mazeView.frame.size.width / 2 -self.player.frame.origin.x, self.mazeView.frame.size.height / 2 -self.player.frame.origin.y, self.mazeView.frame.size.width, self.mazeView.frame.size.height);
}

@end