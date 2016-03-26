//
//  PNGameSession.m
//  Psynaut
//
//  Created by mugx on 10/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNGameSession.h"
#import "PNCollisionCollaborator.h"
#import "PNEnemyCollaborator.h"
#import "PNPlayer.h"
#import "PNItem.h"
#import "PNMazeGenerator.h"
#import "PNEnemy.h"
#import "MXToolBox.h"
#import "PNMacros.h"
#import "PNConstants.h"
#import <MXAudioManager/MXAudioManager.h>

@interface PNGameSession ()
@property(nonatomic,assign,readwrite) NSUInteger currentLevel;
@property(nonatomic,assign,readwrite) NSUInteger currentScore;
@property(nonatomic,assign,readwrite) CGFloat currentLives;
@property(nonatomic,assign,readwrite) CGFloat currentTime;
@property(nonatomic,strong,readwrite) NSMutableArray<UIImageView *> *walls;
@property(nonatomic,strong) NSMutableArray<PNItem *> *items;

@property(nonatomic,strong) PNMazeGenerator *mazeGenerator;
@property(nonatomic,assign) NSUInteger tileWidth;
@property(nonatomic,assign) NSUInteger tileHeight;
@property(nonatomic,assign) NSUInteger numRow;
@property(nonatomic,assign) NSUInteger numCol;

@property(nonatomic,assign) int bkgColorIndex;
@property(nonatomic,strong,readwrite) UIView *mazeView;
@property(nonatomic,weak) UIView *gameView;
@property(nonatomic,weak) UIView *endMazeTile;
@end

@implementation PNGameSession

- (void)dealloc
{
  free(_maze);
}

- (instancetype)initWithView:(UIView *)gameView
{
  self = [super init];
  _gameView = gameView;
  return self;
}

- (void)clearSession
{
  for (UIView *view in self.mazeView.subviews)
  {
    [view removeFromSuperview];
  }
}

- (void)startLevel:(NSUInteger)levelNumber
{
  [self clearSession];
  
  //--- setup gameplay varables ---//
  if (levelNumber == 1)
  {
    self.currentScore = 0;
    self.currentLives = 1;
  }
  
  self.currentTime = 60;
  self.currentLevel = levelNumber;
  
  //--- setup maze ---//
  self.tileWidth = TILE_SIZE;
  self.tileHeight = TILE_SIZE;
  self.numCol = 20;
  self.numRow = 20;
  
  //--- init scene elems ---//
  [self initMaze];
  [self initPlayer];
  [self initItems];
  
  ///--- setup collaborator ---//
  self.collisionCollaborator = [[PNCollisionCollaborator alloc] init:self];
  self.enemyCollaborator = [[PNEnemyCollaborator alloc] init:self];
}

- (void)initMaze
{
  self.walls = [NSMutableArray array];
  self.mazeView = [[UIView alloc] initWithFrame:self.gameView.frame];
  [self.gameView addSubview:self.mazeView];
  [self.gameView sendSubviewToBack:self.mazeView];
  
  //--- current bkg color ---//
  //--- updating the background color ---//
  NSArray *colors = @[GREEN_COLOR, CYAN_COLOR, BLUE_COLOR, RED_COLOR, YELLOW_COLOR];
  self.bkgColorIndex = arc4random() % colors.count;
  
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
        [wall setImage:[[UIImage imageNamed:@"wall"] imageColored:colors[self.bkgColorIndex]]];
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
        UIImageView *tile = [[UIImageView alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
        tile.backgroundColor = GREEN_COLOR;
        [self.mazeView addSubview:tile];
        [self.mazeView sendSubviewToBack:tile];
        self.endMazeTile = tile;
      }
    }
  }
}

- (void)initPlayer
{
  self.player = [[PNPlayer alloc] initWithFrame:CGRectMake(STARTING.y * self.tileWidth + PLAYER_PADDING, STARTING.x * self.tileHeight + PLAYER_PADDING, self.tileWidth - PLAYER_SPEED, self.tileHeight - PLAYER_SPEED) withGameSession:self];
  self.player.animationImages = [[UIImage imageNamed:@"player"] spritesWiteSize:CGSizeMake(self.tileWidth, self.tileHeight)];
  self.player.animationDuration = 0.4f;
  self.player.animationRepeatCount = 0;
  [self.player startAnimating];
  [self.mazeView addSubview:self.player];
  [self.mazeView bringSubviewToFront:self.player];
}

- (void)initItems
{
  self.items = [NSMutableArray array];
  for (int r = 0; r < self.numRow ; r++)
  {
    for (int c = 0; c < self.numCol; c++)
    {
      if (self.self.maze[r][c] == MTPath)
      {
        if ((arc4random() % 100) >= 50)
        {
          PNItem *coin = [[PNItem alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
          coin.image = [[UIImage imageNamed:@"coin"] imageColored:[UIColor yellowColor]];
          [self.mazeView addSubview:coin];
          [self.mazeView sendSubviewToBack:coin];
          [self.items addObject:coin];
        }
        else if ((arc4random() % 100) >= 95)
        {
          PNItem *minion = [[PNItem alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
          minion.image = [[UIImage imageNamed:@"minion"] imageColored:[UIColor whiteColor]];
          [self.mazeView addSubview:minion];
          [self.mazeView sendSubviewToBack:minion];
          [self.items addObject:minion];
        }
      }
    }
  }
}

- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction
{
  [self.player didSwipe:direction];
}

- (void)update:(CGFloat)deltaTime
{
  self.currentTime -=deltaTime;
  [self.delegate didUpdateTime:self.currentTime];
  
  //--- updating enemies stuff ---//
  [self.enemyCollaborator update:deltaTime];
  
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
      self.currentScore += 5;
      [self.delegate didUpdateScore:self.currentScore];
      continue;
    }
  }
  [self.items removeObjectsInArray:array];
  
  //--- updating maze frame ---//
  self.mazeView.frame = CGRectMake(self.mazeView.frame.size.width / 2.0 - self.player.frame.origin.x, self.mazeView.frame.size.height / 2.0 - self.player.frame.origin.y, self.mazeView.frame.size.width, self.mazeView.frame.size.height);
  
  
  ///--- collision enemy vs player ---//
  for (PNEnemy *enemy in self.enemyCollaborator.enemies)
  {
    if (CGRectIntersectsRect(enemy.frame, self.player.frame))
    {
      self.currentLives = self.currentLives - 1;
      break;
    }
  }
  
  //--- collision player vs end maze---//
  if (CGRectIntersectsRect(self.player.frame, self.endMazeTile.frame))
  {
    [self startLevel:self.currentLevel + 1];
  }
  
  if (self.currentLives == 0)
  {
    [self.delegate performSelector:@selector(didGameOver:) withObject:self];
  }
}

@end