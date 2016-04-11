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

#define BKG_COLORS @[GREEN_COLOR, CYAN_COLOR, BLUE_COLOR, RED_COLOR, YELLOW_COLOR]

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

@property(nonatomic,assign) int bkgColorIndex;
@property(nonatomic,assign) float bkgColorTimeAccumulator;
@property(nonatomic,strong,readwrite) UIView *mazeView;
@property(nonatomic,weak) UIView *gameView;
@property(nonatomic,weak) UIView *mazeGoalTile;
@property(nonatomic,assign) CGAffineTransform rotation;
@property(nonatomic,assign) BOOL keyGenerated;
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
  
  //--- reset random rotation ---//
  self.gameView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
  
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
  self.numCol = 21;
  self.numRow = 21;
  
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
  
  //--- generating the maze ---//
  PNMazeGenerator *mazeGenerator = [PNMazeGenerator new];
  self.maze = [mazeGenerator calculateMaze:self.numRow col:self.numCol startingPosition:STARTING];
  for (int r = 0; r < self.numRow ; r++)
  {
    for (int c = 0; c < self.numCol; c++)
    {
      if (self.maze[r][c] == MTWall)
      {
        PNTile *tile = [[PNTile alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
        [tile setImage:[[UIImage imageNamed:@"wall"] imageColored:BKG_COLORS[self.bkgColorIndex]]];
        self.bkgColorIndex = (self.bkgColorIndex + 1) % (BKG_COLORS.count);
        tile.x = r;
        tile.y = c;
        [self.mazeView addSubview:tile];
        [self.walls addObject:tile];
        [self.mazeView sendSubviewToBack:tile];
      }
      else if (self.maze[r][c] == MTStart)
      {
        PNTile *tile = [[PNTile alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
        tile.x = r;
        tile.y = c;
        [tile setImage:[[UIImage imageNamed:@"door"] imageColored:BLUE_COLOR]];
        [self.mazeView addSubview:tile];
        [self.mazeView sendSubviewToBack:tile];
      }
      else if (self.maze[r][c] == MTEnd)
      {
        PNTile *tile = [[PNTile alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
        //tile.backgroundColor = GREEN_COLOR;
        tile.x = r;
        tile.y = c;
        [tile setImage:[[UIImage imageNamed:@"target"] imageColored:GREEN_COLOR]];
        [self.mazeView addSubview:tile];
        [self.mazeView sendSubviewToBack:tile];
        self.mazeGoalTile = tile;
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
          float iconSize = 20;
          PNItem *coin = [[PNItem alloc] initWithFrame:CGRectMake(c * self.tileWidth + (self.tileWidth - iconSize) / 2.0, r * self.tileHeight + (self.tileHeight - iconSize) / 2.0, iconSize, iconSize)];
          coin.image = [[UIImage imageNamed:@"coin"] imageColored:[UIColor yellowColor]];
          [self.mazeView addSubview:coin];
          [self.mazeView sendSubviewToBack:coin];
          [self.items addObject:coin];
        }
        else if (!self.keyGenerated && (arc4random() % 100) >= 70)
        {
          PNItem *whirlwind = [[PNItem alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
          whirlwind.tag = 2;
          whirlwind.image = [[UIImage imageNamed:@"whirlwind"] imageColored:CYAN_COLOR];
          [self.mazeView addSubview:whirlwind];
          [self.mazeView sendSubviewToBack:whirlwind];
          [self.items addObject:whirlwind];
        }
        else if (!self.keyGenerated && (arc4random() % 100) >= 70)
        {
          PNItem *bomb = [[PNItem alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
          bomb.tag = 1;
          bomb.image = [[UIImage imageNamed:@"bomb"] imageColored:RED_COLOR];
          bomb.x = c;
          bomb.y = r;
          [self.mazeView addSubview:bomb];
          [self.mazeView sendSubviewToBack:bomb];
          [self.items addObject:bomb];
        }
        else if (!self.keyGenerated && (arc4random() % 100) >= 70)
        {
          PNItem *bomb = [[PNItem alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
          bomb.tag = 1;
          bomb.image = [[UIImage imageNamed:@"time"] imageColored:YELLOW_COLOR];
          bomb.x = c;
          bomb.y = r;
          [self.mazeView addSubview:bomb];
          [self.mazeView sendSubviewToBack:bomb];
          [self.items addObject:bomb];
        }
        else if ((arc4random() % 100) >= 95)
        {
          PNItem *minion = [[PNItem alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
          minion.image = [[UIImage imageNamed:@"minion"] imageColored:[UIColor whiteColor]];
          [self.mazeView addSubview:minion];
          [self.mazeView sendSubviewToBack:minion];
          [self.items addObject:minion];
        }
        else if (!self.keyGenerated && (arc4random() % 100) >= 98)
        {
          self.keyGenerated = YES;
          PNItem *key = [[PNItem alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
          key.image = [[UIImage imageNamed:@"key"] imageColored:MAGENTA_COLOR];
          [self.mazeView addSubview:key];
          [self.mazeView sendSubviewToBack:key];
          [self.items addObject:key];
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
  [self.player update:deltaTime];
  
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
      
      if (item.tag == 1)
      {
        int posx = (int)self.player.frame.origin.x;
        int posy = (int)self.player.frame.origin.y;
        int row = item.x;
        int col = item.y;
        NSMutableArray *tileToRemove = [NSMutableArray array];
        for (PNTile *tile in self.walls)
        {
          if (CGRectIntersectsRect(tile.frame, CGRectMake(posx + 32, posy, 32, 32)))
          {
            self.maze[row + 1][col] = MTPath;
            [tile explode:nil];
            [tileToRemove addObject:tile];
          }
          
          if (CGRectIntersectsRect(tile.frame, CGRectMake(posx - 32, posy, 32, 32)))
          {
            self.maze[row - 1][col] = MTPath;
            [tile explode:nil];
            [tileToRemove addObject:tile];
          }
          
          if (CGRectIntersectsRect(tile.frame, CGRectMake(posx, posy + 32, 32, 32)))
          {
            self.maze[row][col + 1] = MTPath;
            [tile explode:nil];
            [tileToRemove addObject:tile];
          }
          
          if (CGRectIntersectsRect(tile.frame, CGRectMake(posx, posy - 32, 32, 32)))
          {
            self.maze[row][col - 1] = MTPath;
            [tile explode:nil];
            [tileToRemove addObject:tile];
          }
        }
        [self.walls removeObjectsInArray:tileToRemove];
      }
      else if (item.tag == 2)
      {
        [UIView animateWithDuration:0.1 animations:^{
          self.gameView.transform = CGAffineTransformRotate(self.gameView.transform, M_PI_2);
        }];
      }
      continue;
    }
  }
  [self.items removeObjectsInArray:array];
  
  //--- updating maze frame ---//
  self.mazeView.frame = CGRectMake(self.mazeView.frame.size.width / 2.0 - self.player.frame.origin.x, self.mazeView.frame.size.height / 2.0 - self.player.frame.origin.y, self.mazeView.frame.size.width, self.mazeView.frame.size.height);
  
  ///--- collision player vs enemies ---//
  for (PNEnemy *enemy in self.enemyCollaborator.enemies)
  {
    if (CGRectIntersectsRect(enemy.frame, self.player.frame))
    {
      self.currentLives = self.currentLives - 1;
      [enemy setHidden:YES];
      break;
    }
  }
  
  //--- collision player vs maze goal---//
  if (CGRectIntersectsRect(self.player.frame, self.mazeGoalTile.frame))
  {
    [self startLevel:self.currentLevel + 1];
  }
  
  //--- collision if player is dead---//
  if (self.currentLives == 0)
  {
    //    [self.player explode:^{
    //        [self.delegate performSelector:@selector(didGameOver:) withObject:self];
    //    }];
  }
}

@end