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

typedef NS_ENUM(NSUInteger, TyleType) {
  TTRedWall = 1,
  TTWall = 2,
  TTCoin = 3,
  TTWhirlwind = 4,
  TTBomb = 5,
  TTTime = 6,
  TTMinion = 7,
  TTKey = 8
};

#define BKG_COLORS @[GREEN_COLOR, CYAN_COLOR, BLUE_COLOR, YELLOW_COLOR, RED_COLOR]

@interface PNGameSession ()
@property(nonatomic,assign,readwrite) NSUInteger currentLevel;
@property(nonatomic,assign,readwrite) NSUInteger currentScore;
@property(nonatomic,assign,readwrite) CGFloat currentLives;
@property(nonatomic,assign,readwrite) CGFloat currentTime;
@property(nonatomic,strong,readwrite) NSMutableArray<UIImageView *> *walls;
@property(nonatomic,strong) NSMutableArray<PNItem *> *items;

@property(nonatomic,strong) PNMazeGenerator *mazeGenerator;
@property(nonatomic,assign) int bkgColorIndex;
@property(nonatomic,assign) float bkgColorTimeAccumulator;
@property(nonatomic,strong,readwrite) UIView *mazeView;
@property(nonatomic,weak) UIView *gameView;
@property(nonatomic,weak) UIView *mazeGoalTile;
@property(nonatomic,assign) float rot;
@property(nonatomic,assign) NSUInteger minionsCount;
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
        PNTile *tile = [[PNTile alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
        if (r == 0 || c == 0 || r == self.numRow - 1 || c == self.numCol - 1)
        {
          [tile setImage:[[UIImage imageNamed:@"wall"] imageColored:RED_COLOR]];
          tile.tag = TTRedWall;
        }
        else
        {
          [tile setImage:[[UIImage imageNamed:@"wall"] imageColored:BKG_COLORS[self.bkgColorIndex]]];
          tile.tag = self.bkgColorIndex == BKG_COLORS.count - 1 ? TTRedWall : TTWall;
          self.bkgColorIndex = (self.bkgColorIndex + 1) % (BKG_COLORS.count);
        }
        
        tile.x = r;
        tile.y = c;
        [self.mazeView addSubview:tile];
        [self.walls addObject:tile];
        [self.mazeView sendSubviewToBack:tile];
      }
      else if (self.maze[r][c] == MTStart)
      {
        PNTile *tile = [[PNTile alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
        tile.x = r;
        tile.y = c;
        [tile setImage:[[UIImage imageNamed:@"door"] imageColored:BLUE_COLOR]];
        [self.mazeView addSubview:tile];
        [self.mazeView sendSubviewToBack:tile];
      }
      else if (self.maze[r][c] == MTEnd)
      {
        PNTile *tile = [[PNTile alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
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
  self.player = [[PNPlayer alloc] initWithFrame:CGRectMake(STARTING.y * TILE_SIZE + PLAYER_PADDING, STARTING.x * TILE_SIZE + PLAYER_PADDING, TILE_SIZE - PLAYER_SPEED, TILE_SIZE - PLAYER_SPEED) withGameSession:self];
  NSArray *images = [[UIImage imageNamed:@"player"] spritesWiteSize:CGSizeMake(TILE_SIZE, TILE_SIZE)];
  NSMutableArray *coloredImages = [@[] mutableCopy];
  for (UIImage *img in images)
  {
    [coloredImages addObject:[img imageColored:CYAN_COLOR]];
  }
  self.player.animationImages = coloredImages;
  self.player.animationDuration = 0.4f;
  self.player.animationRepeatCount = 0;
  [self.player startAnimating];
  [self.mazeView addSubview:self.player];
  [self.mazeView bringSubviewToFront:self.player];
}

- (void)initItems
{
  self.items = [NSMutableArray array];
  self.minionsCount = 0;
  bool keyGenerated = false;
  int minionsGenerated = 0;
  
  for (int r = 0; r < self.numRow ; r++)
  {
    for (int c = 0; c < self.numCol; c++)
    {
      if (self.self.maze[r][c] == MTPath)
      {
        if ((arc4random() % 100) >= 50)
        {
          float iconSize = 20;
          PNItem *coin = [[PNItem alloc] initWithFrame:CGRectMake(c * TILE_SIZE + (TILE_SIZE - iconSize) / 2.0, r * TILE_SIZE + (TILE_SIZE - iconSize) / 2.0, iconSize, iconSize)];
          coin.tag = TTCoin;
          coin.image = [[UIImage imageNamed:@"coin"] imageColored:[UIColor yellowColor]];
          [self.mazeView addSubview:coin];
          [self.mazeView sendSubviewToBack:coin];
          [self.items addObject:coin];
        }
        else if ((arc4random() % 100) >= 70)
        {
          PNItem *whirlwind = [[PNItem alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
          whirlwind.tag = TTWhirlwind;
          whirlwind.image = [[UIImage imageNamed:@"whirlwind"] imageColored:CYAN_COLOR];
          [self.mazeView addSubview:whirlwind];
          [self.mazeView sendSubviewToBack:whirlwind];
          [self.items addObject:whirlwind];
        }
        else if ((arc4random() % 100) >= 70)
        {
          PNItem *bomb = [[PNItem alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
          bomb.tag = TTBomb;
          bomb.image = [[UIImage imageNamed:@"bomb"] imageColored:RED_COLOR];
          bomb.x = c;
          bomb.y = r;
          [self.mazeView addSubview:bomb];
          [self.mazeView sendSubviewToBack:bomb];
          [self.items addObject:bomb];
        }
        else if ((arc4random() % 100) >= 70)
        {
          PNItem *bomb = [[PNItem alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
          bomb.tag = TTTime;
          bomb.image = [[UIImage imageNamed:@"time"] imageColored:YELLOW_COLOR];
          bomb.x = c;
          bomb.y = r;
          [self.mazeView addSubview:bomb];
          [self.mazeView sendSubviewToBack:bomb];
          [self.items addObject:bomb];
        }
        else if (minionsGenerated < 4 && (arc4random() % 100) >= 95)
        {
          ++minionsGenerated;
          PNItem *minion = [[PNItem alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
          minion.tag = TTMinion;
          minion.image = [[UIImage imageNamed:@"minion"] imageColored:[UIColor whiteColor]];
          [self.mazeView addSubview:minion];
          [self.mazeView sendSubviewToBack:minion];
          [self.items addObject:minion];
        }
        else if (!keyGenerated && (arc4random() % 100) >= 98)
        {
          keyGenerated = true;
          PNItem *key = [[PNItem alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
          key.tag = TTKey;
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
  NSMutableArray *itemsToRemove = [NSMutableArray array];
  for (PNItem *item in self.items)
  {
    if (CGRectIntersectsRect(item.frame, self.player.frame))
    {
      item.hidden = true;
      [itemsToRemove addObject:item];
      
      if (item.tag == TTCoin)
      {
        [[MXAudioManager sharedInstance] play:STHitCoin];
        self.currentScore += 5;
        [self.delegate didUpdateScore:self.currentScore];
      }
      else if (item.tag == TTWhirlwind)
      {
        [[MXAudioManager sharedInstance] play:STHitWhirlwind];
        [UIView animateWithDuration:0.1 animations:^{
          self.rot += M_PI_2;
          self.gameView.transform = CGAffineTransformRotate(self.gameView.transform, M_PI_2);
        }];
      }
      else if (item.tag == TTTime)
      {
        [[MXAudioManager sharedInstance] play:STHitTimeBonus];
        self.currentTime += 5;
      }
      else if (item.tag == TTMinion)
      {
        [[MXAudioManager sharedInstance] play:STHitMinion];
        ++self.minionsCount;
        [self.delegate didGotMinion:self.minionsCount];
      }
      else if (item.tag == TTBomb)
      {
        [[MXAudioManager sharedInstance] play:STHitBomb];
        int posx = (int)self.player.frame.origin.x;
        int posy = (int)self.player.frame.origin.y;
        int row = item.x;
        int col = item.y;
        NSMutableArray *tileToRemove = [NSMutableArray array];
        for (PNTile *tile in self.walls)
        {
          if (CGRectIntersectsRect(tile.frame, CGRectMake(posx + TILE_SIZE, posy, TILE_SIZE, TILE_SIZE)) && tile.tag != TTRedWall)
          {
            self.maze[row + 1][col] = MTPath;
            [tile explode:nil];
            [tileToRemove addObject:tile];
          }
          
          if (CGRectIntersectsRect(tile.frame, CGRectMake(posx - TILE_SIZE, posy, TILE_SIZE, TILE_SIZE)) && tile.tag != TTRedWall)
          {
            self.maze[row - 1][col] = MTPath;
            [tile explode:nil];
            [tileToRemove addObject:tile];
          }
          
          if (CGRectIntersectsRect(tile.frame, CGRectMake(posx, posy + TILE_SIZE, TILE_SIZE, TILE_SIZE)) && tile.tag != TTRedWall)
          {
            self.maze[row][col + 1] = MTPath;
            [tile explode:nil];
            [tileToRemove addObject:tile];
          }
          
          if (CGRectIntersectsRect(tile.frame, CGRectMake(posx, posy - TILE_SIZE, TILE_SIZE, TILE_SIZE)) && tile.tag != TTRedWall)
          {
            self.maze[row][col - 1] = MTPath;
            [tile explode:nil];
            [tileToRemove addObject:tile];
          }
        }
        [self.walls removeObjectsInArray:tileToRemove];
      }
    }
    item.transform = CGAffineTransformMakeRotation(-self.rot);
  }
  [self.items removeObjectsInArray:itemsToRemove];
  
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
    [self.delegate didNextLevel:self.currentLevel];
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