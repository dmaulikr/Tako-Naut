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

#define BASE_MAZE_DIMENSION 5
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
@property(nonatomic,weak) PNItem *mazeGoalTile;
@property(nonatomic,assign) float mazeRotation;
@property(nonatomic,assign) NSUInteger minionsCount;
@property(nonatomic,assign) BOOL isGameOver;
@end

@implementation PNGameSession

- (instancetype)initWithView:(UIView *)gameView
{
  self = [super init];
  _gameView = gameView;
  return self;
}

- (void)startLevel:(NSUInteger)levelNumber
{
  //--- setup gameplay varables ---//
  self.currentLevel = levelNumber;
  self.currentTime = 60;
  
  if (levelNumber == 1)
  {
    //--- play start game sound ---//
    [[MXAudioManager sharedInstance] play:STStartgame];
    self.currentScore = 0;
    self.currentLives = 1;
    self.numCol = BASE_MAZE_DIMENSION;
    self.numRow = BASE_MAZE_DIMENSION;
  }
  else
  {
    //--- play start level sound ---//
    [[MXAudioManager sharedInstance] play:STLevelChange];
  }
  
  //--- reset random rotation ---//
  self.gameView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0);
  
  //--- remove old views ---//
  for (UIView *view in self.mazeView.subviews)
  {
    [view removeFromSuperview];
  }
  
  //--- init scene elements ---//
  self.numCol = (self.numCol + 2) < 30 ? self.numCol + 2 : self.numCol;
  self.numRow = (self.numRow + 2) < 30 ? self.numRow + 2 : self.numRow;
  [self makeMaze];
  [self makePlayer];
  
  ///--- setup collaborator ---//
  self.collisionCollaborator = [[PNCollisionCollaborator alloc] init:self];
  self.enemyCollaborator = [[PNEnemyCollaborator alloc] init:self];
}

- (void)makeMaze
{
  self.items = [NSMutableArray array];
  self.mazeView = [[UIView alloc] initWithFrame:self.gameView.frame];
  [self.gameView addSubview:self.mazeView];
  [self.gameView sendSubviewToBack:self.mazeView];
  self.bkgColorIndex = (self.bkgColorIndex + 1) % (BKG_COLORS.count);
  self.mazeRotation = 0;
  self.minionsCount = 0;
  self.isGameOver = NO;
  
  //--- generating the maze ---//
  PNMazeGenerator *mazeGenerator = [PNMazeGenerator new];
  MazeTyleType **maze = [mazeGenerator calculateMaze:self.numRow col:self.numCol startingPosition:STARTING];
  self.wallsDictionary = [NSMutableDictionary dictionary];
  
  NSMutableArray *freeTiles = [NSMutableArray array];
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
        [self.mazeView addSubview:tile];
        [self.mazeView sendSubviewToBack:tile];
        [self.items addObject:tile];
      }
      else if (maze[r][c] == MTEnd)
      {
        PNItem *tile = [[PNItem alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
        tile.x = r;
        tile.y = c;
        tile.tag = TTMazeEnd_close;
        [tile setImage:[[UIImage imageNamed:@"gate_close"] imageColored:MAGENTA_COLOR]];
        [self.mazeView addSubview:tile];
        [self.mazeView sendSubviewToBack:tile];
        self.mazeGoalTile = tile;
        [self.items addObject:tile];
      }
      else
      {
        PNItem *item = [self makeItem:c row:r];
        if (!item)
        {
          [freeTiles addObject:@{@"c":@(c), @"r":@(r)}];
        }
      }
    }
  }
  
  //--- make key ---//
  NSDictionary *keyPosition = freeTiles[arc4random() % freeTiles.count];
  NSUInteger c = [keyPosition[@"c"] unsignedIntegerValue];
  NSUInteger r = [keyPosition[@"r"] unsignedIntegerValue];
  PNItem *keyItem = [[PNItem alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
  keyItem.x = c;
  keyItem.y = r;
  keyItem.tag = TTKey;
  keyItem.image = [[UIImage imageNamed:@"key"] imageColored:MAGENTA_COLOR];
  [self.mazeView addSubview:keyItem];
  [self.mazeView sendSubviewToBack:keyItem];
  [self.items addObject:keyItem];
  
  for (int i = 0; i < self.numCol; ++i)
  {
    free(maze[i]);
  }
  free(maze);
}

- (PNItem *)makeItem:(int)col row:(int)row
{
  int tag = -1;
  UIImage *image = nil;
  if ((arc4random() % 100) >= 50)
  {
    tag = TTCoin;
    image = [[UIImage imageNamed:@"coin"] imageColored:[UIColor yellowColor]];
  }
  else if ((arc4random() % 100) >= 90)
  {
    tag = TTWhirlwind;
    image = [[UIImage imageNamed:@"whirlwind"] imageColored:BKG_COLORS[self.bkgColorIndex]];
  }
  else if ((arc4random() % 100) >= 80)
  {
    tag = TTBomb;
    image = [[UIImage imageNamed:@"bomb"] imageColored:RED_COLOR];
  }
  else if ((arc4random() % 100) >= 90)
  {
    tag = TTTime;
    image = [[UIImage imageNamed:@"time"] imageColored:MAGENTA_COLOR];
  }
  
  if (tag != -1)
  {
    PNItem *item = [[PNItem alloc] initWithFrame:CGRectMake(col * TILE_SIZE, row * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
    item.x = col;
    item.y = row;
    item.tag = tag;
    item.image = image;
    [self.mazeView addSubview:item];
    [self.mazeView sendSubviewToBack:item];
    [self.items addObject:item];
    return item;
  }
  else
  {
    return nil;
  }
}

- (void)makePlayer
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
        [[MXAudioManager sharedInstance] play:STHitCoin];
        item.hidden = true;
        [itemsToRemove addObject:item];
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
        [[MXAudioManager sharedInstance] play:STHitTimeBonus];
        item.hidden = true;
        [itemsToRemove addObject:item];
        self.currentTime += 5;
      }
      else if (item.tag == TTKey)
      {
        item.hidden = true;
        [itemsToRemove addObject:item];
        
        [[MXAudioManager sharedInstance] play:STHitTimeBonus];
        self.mazeGoalTile.tag = TTMazeEnd_open;
        [self.mazeGoalTile setImage:[[UIImage imageNamed:@"gate_open"] imageColored:MAGENTA_COLOR]];
      }
      else if (item.tag == TTMinion)
      {
        [[MXAudioManager sharedInstance] play:STHitMinion];
        item.hidden = true;
        [itemsToRemove addObject:item];
        ++self.minionsCount;
        [self.delegate didGotMinion:self.minionsCount];
      }
      else if (item.tag == TTBomb)
      {
        [[MXAudioManager sharedInstance] play:STHitBomb];
        item.hidden = true;
        [itemsToRemove addObject:item];
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
            break;
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
  if (self.mazeGoalTile.tag == TTMazeEnd_open  && CGRectIntersectsRect(self.player.frame, self.mazeGoalTile.frame))
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