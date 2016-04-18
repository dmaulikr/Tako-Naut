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

#define BKG_COLORS @[BLUE_COLOR, GREEN_COLOR, CYAN_COLOR, YELLOW_COLOR, RED_COLOR]

@interface PNGameSession ()
@property(nonatomic,assign,readwrite) NSUInteger currentLevel;
@property(nonatomic,assign,readwrite) NSUInteger currentScore;
@property(nonatomic,assign,readwrite) CGFloat currentLives;
@property(nonatomic,assign,readwrite) CGFloat currentTime;
@property(nonatomic,strong,readwrite) NSMutableDictionary<NSValue*, PNTile *> *wallsDictionary;
@property(nonatomic,strong) NSMutableArray<PNItem *> *items;

@property(nonatomic,strong) PNMazeGenerator *mazeGenerator;
@property(nonatomic,assign) int bkgColorIndex;
@property(nonatomic,assign) float bkgColorTimeAccumulator;
@property(nonatomic,strong,readwrite) UIView *mazeView;
@property(nonatomic,weak) UIView *gameView;
@property(nonatomic,weak) UIView *mazeGoalTile;
@property(nonatomic,assign) float mazeRotation;
@property(nonatomic,assign) NSUInteger minionsCount;
@property(nonatomic,assign) BOOL keyGenerated;
@property(nonatomic,assign) BOOL isGameOver;
@end

@implementation PNGameSession

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
  [[MXAudioManager sharedInstance] play:STLevelChange];
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
  
  ///--- setup collaborator ---//
  self.collisionCollaborator = [[PNCollisionCollaborator alloc] init:self];
  self.enemyCollaborator = [[PNEnemyCollaborator alloc] init:self];
}

- (void)initMaze
{
  self.items = [NSMutableArray array];
  self.mazeView = [[UIView alloc] initWithFrame:self.gameView.frame];
  [self.gameView addSubview:self.mazeView];
  [self.gameView sendSubviewToBack:self.mazeView];
  self.bkgColorIndex = (self.bkgColorIndex + 1) % (BKG_COLORS.count);
  self.mazeRotation = 0;
  self.minionsCount = 0;
  self.keyGenerated = false;
  self.isGameOver = NO;
  
  //--- generating the maze ---//
  PNMazeGenerator *mazeGenerator = [PNMazeGenerator new];
  MazeTyleType **maze = [mazeGenerator calculateMaze:self.numRow col:self.numCol startingPosition:STARTING];
  self.wallsDictionary = [NSMutableDictionary dictionary];
  
  for (int r = 0; r < self.numRow ; r++)
  {
    for (int c = 0; c < self.numCol; c++)
    {
      if (maze[r][c] == MTWall)
      {
        PNTile *tile = [[PNTile alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
        if (r == 0 || c == 0 || r == self.numRow - 1 || c == self.numCol - 1)
        {
          [tile setImage:[[UIImage imageNamed:@"wall"] imageColored:BKG_COLORS[self.bkgColorIndex]]];
          tile.tag = TTBorderdWall;
        }
        else
        {
          [tile setImage:[[UIImage imageNamed:@"wall"] imageColored:BKG_COLORS[self.bkgColorIndex]]];
          tile.tag = TTWall;
        }
        
        tile.x = r;
        tile.y = c;
        [self.mazeView addSubview:tile];
        [self.wallsDictionary setObject:tile forKey:[NSValue valueWithCGPoint:CGPointMake(r, c)]];
        [self.mazeView sendSubviewToBack:tile];
      }
      else if (maze[r][c] == MTStart)
      {
        PNItem *tile = [[PNItem alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
        tile.x = r;
        tile.y = c;
        tile.tag = TTDoor;
        [tile setImage:[[UIImage imageNamed:@"door"] imageColored:BLUE_COLOR]];
        [self.mazeView addSubview:tile];
        [self.mazeView sendSubviewToBack:tile];
        [self.items addObject:tile];
      }
      else if (maze[r][c] == MTEnd)
      {
        PNItem *tile = [[PNItem alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
        tile.x = r;
        tile.y = c;
        tile.tag = TTMazeEnd;
        [tile setImage:[[UIImage imageNamed:@"target"] imageColored:GREEN_COLOR]];
        [self.mazeView addSubview:tile];
        [self.mazeView sendSubviewToBack:tile];
        self.mazeGoalTile = tile;
        [self.items addObject:tile];
      }
      else
      {
        [self initItem:c row:r];
      }
    }
  }
  
  for (int i = 0; i < self.numCol; ++i)
  {
    free(maze[i]);
  }
  free(maze);
}

- (void)initItem:(int)col row:(int)row
{
  PNItem *item = [[PNItem alloc] initWithFrame:CGRectMake(col * TILE_SIZE, row * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
  item.x = col;
  item.y = row;
  [self.mazeView addSubview:item];
  [self.mazeView sendSubviewToBack:item];
  [self.items addObject:item];
  
  if ((arc4random() % 100) >= 50)
  {
    item.tag = TTCoin;
    item.image = [[UIImage imageNamed:@"coin"] imageColored:[UIColor yellowColor]];
  }
  else if ((arc4random() % 100) >= 90)
  {
    item.tag = TTWhirlwind;
    item.image = [[UIImage imageNamed:@"whirlwind"] imageColored:BKG_COLORS[self.bkgColorIndex]];
  }
  else if ((arc4random() % 100) >= 80)
  {
    item.tag = TTBomb;
    item.image = [[UIImage imageNamed:@"bomb"] imageColored:RED_COLOR];
  }
  else if ((arc4random() % 100) >= 90)
  {
    item.tag = TTTime;
    item.image = [[UIImage imageNamed:@"time"] imageColored:MAGENTA_COLOR];
  }
  else if (self.minionsCount < 4 && (arc4random() % 100) >= 95)
  {
    ++self.minionsCount;
    item.tag = TTMinion;
    item.image = [[UIImage imageNamed:@"minion"] imageColored:[UIColor whiteColor]];
  }
  else if (!self.keyGenerated && (arc4random() % 100) >= 98)
  {
    self.keyGenerated = true;
    item.tag = TTKey;
    item.image = [[UIImage imageNamed:@"key"] imageColored:MAGENTA_COLOR];
  }
}

- (void)initPlayer
{
  self.player = [[PNPlayer alloc] initWithFrame:CGRectMake(STARTING.y * TILE_SIZE + PLAYER_SPEED / 2.0, STARTING.x * TILE_SIZE + PLAYER_SPEED / 2.0, TILE_SIZE - PLAYER_SPEED, TILE_SIZE - PLAYER_SPEED) withGameSession:self];
  NSArray *images = [[UIImage imageNamed:@"player"] spritesWiteSize:CGSizeMake(TILE_SIZE, TILE_SIZE)];
  NSMutableArray *coloredImages = [@[] mutableCopy];
  for (UIImage *img in images)
  {
    [coloredImages addObject:[img imageColored:MAGENTA_COLOR]];
  }
  self.player.animationImages = coloredImages;
  self.player.animationDuration = 0.4f;
  self.player.animationRepeatCount = 0;
  [self.player startAnimating];
  [self.mazeView addSubview:self.player];
  [self.mazeView bringSubviewToFront:self.player];
}

- (void)didSwipe:(UISwipeGestureRecognizerDirection)direction
{
  [self.player didSwipe:direction];
}

- (void)update:(CGFloat)deltaTime
{
  self.currentTime = self.currentTime - deltaTime > 0 ? self.currentTime - deltaTime : 0;
  [self.delegate didUpdateTime:self.currentTime];
  
  //--- updating enemies stuff ---//
  [self.enemyCollaborator update:deltaTime];
  
  //--- checking walls collisions ---//
  if (!self.isGameOver)
  {
    [self.player update:deltaTime];
  }
  
  //--- checking items collisions ---//
  NSMutableArray *itemsToRemove = [NSMutableArray array];
  for (PNItem *item in self.items)
  {
    if (CGRectIntersectsRect(item.frame, self.player.frame))
    {
      if (item.tag == TTCoin)
      {
        item.hidden = true;
        [itemsToRemove addObject:item];
        
        [[MXAudioManager sharedInstance] play:STHitCoin];
        self.currentScore += 5;
        [self.delegate didUpdateScore:self.currentScore];
      }
      else if (item.tag == TTWhirlwind)
      {
        item.hidden = true;
        [itemsToRemove addObject:item];
        
        [[MXAudioManager sharedInstance] play:STHitWhirlwind];
        [UIView animateWithDuration:0.2 animations:^{
          self.mazeRotation += M_PI_2;
          self.gameView.transform = CGAffineTransformRotate(self.gameView.transform, M_PI_2);
        }];
      }
      else if (item.tag == TTTime)
      {
        item.hidden = true;
        [itemsToRemove addObject:item];
        
        [[MXAudioManager sharedInstance] play:STHitTimeBonus];
        self.currentTime += 5;
      }
      else if (item.tag == TTMinion)
      {
        item.hidden = true;
        [itemsToRemove addObject:item];
        
        [[MXAudioManager sharedInstance] play:STHitMinion];
        ++self.minionsCount;
        [self.delegate didGotMinion:self.minionsCount];
      }
      else if (item.tag == TTBomb)
      {
        item.hidden = true;
        [itemsToRemove addObject:item];
        
        [[MXAudioManager sharedInstance] play:STHitBomb];
        int player_x = (int)self.player.frame.origin.x;
        int player_y = (int)self.player.frame.origin.y;
        for (PNTile *tile in [self.wallsDictionary allValues])
        {
          if (CGRectIntersectsRect(tile.frame, CGRectMake(player_x + TILE_SIZE, player_y, TILE_SIZE, TILE_SIZE)) && tile.tag != TTBorderdWall)
          {
            [tile explode:nil];
            tile.tag = TTExplodedWall;
          }
          
          if (CGRectIntersectsRect(tile.frame, CGRectMake(player_x - TILE_SIZE, player_y, TILE_SIZE, TILE_SIZE)) && tile.tag != TTBorderdWall)
          {
            [tile explode:nil];
            tile.tag = TTExplodedWall;
          }
          
          if (CGRectIntersectsRect(tile.frame, CGRectMake(player_x, player_y + TILE_SIZE, TILE_SIZE, TILE_SIZE)) && tile.tag != TTBorderdWall)
          {
            [tile explode:nil];
            tile.tag = TTExplodedWall;
          }
          
          if (CGRectIntersectsRect(tile.frame, CGRectMake(player_x, player_y - TILE_SIZE, TILE_SIZE, TILE_SIZE)) && tile.tag != TTBorderdWall)
          {
            [tile explode:nil];
            tile.tag = TTExplodedWall;
          }
        }
      }
    }
    else
    {
      if (item.tag == TTBomb)
      {
        for (PNEnemy *enemy in self.enemyCollaborator.enemies)
        {
          if (CGRectIntersectsRect(enemy.frame, item.frame))
          {
            item.hidden = true;
            [itemsToRemove addObject:item];
            enemy.wantSpawn = YES;
            [[MXAudioManager sharedInstance] play:STEnemySpawn];
          }
        }
      }
    }
    item.transform = CGAffineTransformMakeRotation(-self.mazeRotation);
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
      // [enemy setHidden:YES];
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
  if (!self.isGameOver && (self.currentLives == 0 || self.currentTime <= 0))
  {
    self.isGameOver = YES;
    [[MXAudioManager sharedInstance] play:STGameOver];
    [self.player explode:^{
      [self.delegate performSelector:@selector(didGameOver:) withObject:self];
    }];
  }
}

@end