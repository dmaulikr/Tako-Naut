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
  TTDoor = 0,
  TTRedWall = 1,
  TTWall = 2,
  TTCoin = 3,
  TTWhirlwind = 4,
  TTBomb = 5,
  TTTime = 6,
  TTMinion = 7,
  TTKey = 8,
  TTMazeEnd = 9,
};

#define BKG_COLORS @[BLUE_COLOR, GREEN_COLOR, CYAN_COLOR, YELLOW_COLOR, RED_COLOR]

@interface PNGameSession ()
@property(nonatomic,assign,readwrite) NSUInteger currentLevel;
@property(nonatomic,assign,readwrite) NSUInteger currentScore;
@property(nonatomic,assign,readwrite) CGFloat currentLives;
@property(nonatomic,assign,readwrite) CGFloat currentTime;
@property(nonatomic,strong,readwrite) NSMutableDictionary<NSValue*, PNTile *> *wallsDictionary;
@property(nonatomic,assign) MazeTyleType **maze;
@property(nonatomic,strong) NSMutableArray<PNItem *> *items;

@property(nonatomic,strong) PNMazeGenerator *mazeGenerator;
@property(nonatomic,assign) int bkgColorIndex;
@property(nonatomic,assign) float bkgColorTimeAccumulator;
@property(nonatomic,strong,readwrite) UIView *mazeView;
@property(nonatomic,weak) UIView *gameView;
@property(nonatomic,weak) UIView *mazeGoalTile;
@property(nonatomic,assign) float mazeRotation;
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
  [self initItems];
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
  
  //--- generating the maze ---//
  PNMazeGenerator *mazeGenerator = [PNMazeGenerator new];
  self.maze = [mazeGenerator calculateMaze:self.numRow col:self.numCol startingPosition:STARTING];
  self.wallsDictionary = [NSMutableDictionary dictionary];
  
  for (int r = 0; r < self.numRow ; r++)
  {
    for (int c = 0; c < self.numCol; c++)
    {
      if (self.maze[r][c] == MTWall)
      {
        PNTile *tile = [[PNTile alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
        if (r == 0 || c == 0 || r == self.numRow - 1 || c == self.numCol - 1)
        {
          [tile setImage:[[UIImage imageNamed:@"wall"] imageColored:BKG_COLORS[self.bkgColorIndex]]];
          tile.tag = TTRedWall;
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
      else if (self.maze[r][c] == MTStart)
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
      else if (self.maze[r][c] == MTEnd)
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
    }
  }
}

- (void)initItems
{
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
        else if ((arc4random() % 100) >= 90)
        {
          PNItem *whirlwind = [[PNItem alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
          whirlwind.tag = TTWhirlwind;
          whirlwind.image = [[UIImage imageNamed:@"whirlwind"] imageColored:BKG_COLORS[self.bkgColorIndex]];
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
        else if ((arc4random() % 100) >= 90)
        {
          PNItem *bomb = [[PNItem alloc] initWithFrame:CGRectMake(c * TILE_SIZE, r * TILE_SIZE, TILE_SIZE, TILE_SIZE)];
          bomb.tag = TTTime;
          bomb.image = [[UIImage imageNamed:@"time"] imageColored:MAGENTA_COLOR];
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
  [self.player update:deltaTime];
  
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
        [UIView animateWithDuration:0.1 animations:^{
          //self.mazeRotation += M_PI_2;
          //self.gameView.transform = CGAffineTransformRotate(self.gameView.transform, M_PI_2);
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
        //continue;
        item.hidden = true;
        [itemsToRemove addObject:item];
        
        [[MXAudioManager sharedInstance] play:STHitBomb];
        int posx = (int)self.player.frame.origin.x;
        int posy = (int)self.player.frame.origin.y;
        for (PNTile *tile in [self.wallsDictionary allValues])
        {
          if (CGRectIntersectsRect(tile.frame, CGRectMake(posx + TILE_SIZE, posy, TILE_SIZE, TILE_SIZE)) && tile.tag != TTRedWall)
          {
            [tile explode:nil];
          }
          
          if (CGRectIntersectsRect(tile.frame, CGRectMake(posx - TILE_SIZE, posy, TILE_SIZE, TILE_SIZE)) && tile.tag != TTRedWall)
          {
            [tile explode:nil];
          }
          
          if (CGRectIntersectsRect(tile.frame, CGRectMake(posx, posy + TILE_SIZE, TILE_SIZE, TILE_SIZE)) && tile.tag != TTRedWall)
          {
            [tile explode:nil];
          }
          
          if (CGRectIntersectsRect(tile.frame, CGRectMake(posx, posy - TILE_SIZE, TILE_SIZE, TILE_SIZE)) && tile.tag != TTRedWall)
          {
            [tile explode:nil];
          }
        }
        //[self.wallsDictionary removeObjectForKey:[NSValue valueWithCGPoint:CGPointMake(row, col)]];
      }
    }
    //item.transform = CGAffineTransformMakeRotation(-self.mazeRotation);
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
  if (self.currentLives == 0)
  {
    //    [self.player explode:^{
    //        [self.delegate performSelector:@selector(didGameOver:) withObject:self];
    //    }];
  }
}

@end