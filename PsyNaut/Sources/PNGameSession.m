//
//  PNGameSession.m
//  Psynaut
//
//  Created by mugx on 10/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNGameSession.h"
#import "PNItem.h"
#import "PNMazeGenerator.h"
#import "MXToolBox.h"
#import "PNConstants.h"
#import <MXAudioManager/MXAudioManager.h>

#define TILE_SIZE 32
#define STARTING_X 1
#define STARTING_Y 1

@interface PNGameSession ()
@property(nonatomic,assign,readwrite) NSUInteger currentLevel;
@property(nonatomic,assign,readwrite) NSUInteger currentScore;
@property(nonatomic,assign,readwrite) CGFloat currentTime;
@property(nonatomic,strong) NSMutableArray<UIImageView *> *walls;
@property(nonatomic,strong) NSMutableArray<PNItem *> *items;

@property(nonatomic,strong) PNMazeGenerator *mazeGenerator;
@property(nonatomic,assign) NSUInteger tileWidth;
@property(nonatomic,assign) NSUInteger tileHeight;
@property(nonatomic,assign) MazeTyleType **maze;
@property(nonatomic,assign) NSUInteger row;
@property(nonatomic,assign) NSUInteger col;

@property(nonatomic,strong) UIView *mazeView;
@property(nonatomic,weak) UIView *gameView;
@end

@implementation PNGameSession

- (instancetype)initWithView:(UIView *)view
{
  self = [super init];
  _gameView = view;
  self.currentScore = 0;
  self.currentLevel = 1;
  _walls = [NSMutableArray array];
  _items = [NSMutableArray array];
  _player = [PNPlayer new];
  
  self.walls = [NSMutableArray array];
  
  //--- setup maze ---//
  self.tileWidth = TILE_SIZE;
  self.tileHeight = TILE_SIZE;
  self.col = 15;
  self.row = 15;
  self.mazeGenerator = [[PNMazeGenerator alloc] initWithRow:self.row col:self.col startingPosition:CGPointMake(STARTING_X, STARTING_Y)];
  
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
  
  
  [self.mazeGenerator calculateMaze:^(MazeTyleType **maze)
   {
     self.maze = maze;
     for (int r = 0; r < self.row ; r++)
     {
       for (int c = 0; c < self.col; c++)
       {
         if (maze[r][c] == MTWall)
         {
           UIImageView *wall = [[UIImageView alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
           [wall setImage:[UIImage imageNamed:@"wall"]];
           [self.mazeView addSubview:wall];
           [self.walls addObject:wall];
           [self.mazeView sendSubviewToBack:wall];
         }
         else if (maze[r][c] == MTStart)
         {
           UIImageView *wall = [[UIImageView alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
           wall.backgroundColor = [UIColor whiteColor];
           [self.mazeView addSubview:wall];
           [self.mazeView sendSubviewToBack:wall];
         }
         else if (maze[r][c] == MTEnd)
         {
           UIImageView *wall = [[UIImageView alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
           wall.backgroundColor = [UIColor greenColor];
           [self.mazeView addSubview:wall];
           [self.mazeView sendSubviewToBack:wall];
         }
       }
     }
   }];
}

- (void)initPlayer
{
  UIImage *spriteSheet = [UIImage imageNamed:@"octopus"];
  NSArray *arrayWithSprites = [spriteSheet spritesWithSpriteSheetImage:spriteSheet spriteSize:CGSizeMake(self.tileWidth, self.tileHeight)];
  self.player = [[PNPlayer alloc] initWithFrame:CGRectMake(STARTING_Y * self.tileWidth, STARTING_X * self.tileHeight, self.tileWidth - 1, self.tileHeight - 1)];
  [self.player setAnimationImages:arrayWithSprites];
  self.player.animationDuration = 0.4f;
  self.player.animationRepeatCount = 0;
  [self.player startAnimating];
  [self.mazeView addSubview:self.player];
  [self.mazeView bringSubviewToFront:self.player];
}

- (void)initItems
{
  for (int r = 0; r < self.row ; r++)
  {
    for (int c = 0; c < self.col; c++)
    {
      if (self.maze[r][c] == MTPath)
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

- (void)initOpponent
{
  
}

- (void)checkCollisionFor:(CGPoint)velocity collideX:(BOOL *)collideX collideY:(BOOL *)collideY
{
  CGRect playerFrame = CGRectMake(self.player.frame.origin.x + velocity.x, self.player.frame.origin.y + velocity.y, self.player.frame.size.width, self.player.frame.size.height);
  for (UIView *wall in self.walls)
  {
    if (CGRectIntersectsRect(wall.frame, playerFrame))
    {
      CGRect testRect_x = CGRectMake(self.player.frame.origin.x + velocity.x, self.player.frame.origin.y, self.player.frame.size.width, self.player.frame.size.height);
      if (CGRectIntersectsRect(wall.frame, testRect_x))
      {
        *collideX = YES;
      }
      
      CGRect testRect_y = CGRectMake(self.player.frame.origin.x, self.player.frame.origin.y + velocity.y, self.player.frame.size.width, self.player.frame.size.height);
      if (CGRectIntersectsRect(wall.frame, testRect_y))
      {
        *collideY = YES;
      }
    }
  }
}

- (void)update:(CGFloat)deltaTime
{
  //--- walls collision detection ---//
  CGPoint tempVelocity = self.player.velocity;
  tempVelocity.x += tempVelocity.x * deltaTime;
  tempVelocity.y += tempVelocity.y * deltaTime;
  
  BOOL collideX = NO;
  BOOL collideY = NO;
  [self checkCollisionFor:CGPointMake(tempVelocity.x, tempVelocity.y) collideX:&collideX collideY:&collideY];
  
  if (collideX)
  {
    tempVelocity.x = 0;
  }
  
  if (collideY)
  {
    tempVelocity.y = 0;
  }
  
  //--- updating player frame ---//
  if (tempVelocity.x == 0 && tempVelocity.y == 0)
  {
    self.player.velocity = CGPointMake(0, 0);
    self.player.frame = CGRectMake((int)self.player.frame.origin.x, (int)self.player.frame.origin.y, self.player.frame.size.width, self.player.frame.size.height);
  }
  else
  {
    self.player.frame = CGRectMake(self.player.frame.origin.x + tempVelocity.x, self.player.frame.origin.y + tempVelocity.y, self.player.frame.size.width, self.player.frame.size.height);
  }
  
  //--- items collision detection ---//
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