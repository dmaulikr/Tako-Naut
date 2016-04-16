//
//  PNEnemyCollaborator.m
//  Psynaut
//
//  Created by mugx on 23/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNEnemyCollaborator.h"
#import "PNEnemy.h"
#import "MXToolBox.h"

#define MAX_ENEMIES 5

@interface PNEnemyCollaborator()
@property(nonatomic,weak) PNGameSession *gameSession;
@property(nonatomic,assign) float enemyTimeAccumulator;
@property(nonatomic,strong,readwrite) NSMutableArray *enemies;
@property(nonatomic,strong,readwrite) NSMutableArray *spawnableEnemies;
@property(nonatomic,assign) BOOL medusaWasOut;
@end

@implementation PNEnemyCollaborator

- (instancetype)init:(PNGameSession *)gameSession
{
  self = [super init];
  _gameSession = gameSession;
  [self _initEnemies];
  return self;
}

#pragma mark - Private Functions

- (void)_initEnemies
{
  self.enemies = [NSMutableArray array];
  self.spawnableEnemies = [NSMutableArray array];
  for (int i = 0;i < MAX_ENEMIES;++i)
  {
    PNEnemy *enemy = [[PNEnemy alloc] initWithFrame:CGRectMake(STARTING.y * TILE_SIZE + ENEMY_SPEED / 2.0, STARTING.x * TILE_SIZE + ENEMY_SPEED / 2.0, TILE_SIZE - ENEMY_SPEED, TILE_SIZE - ENEMY_SPEED) withGameSession:self.gameSession];
    enemy.animationDuration = 0.4f;
    enemy.animationRepeatCount = 0;
    enemy.alpha = 0.0;
    enemy.hidden = YES;
    enemy.wantSpawn = i == 0;
    [self.gameSession.mazeView addSubview:enemy];
    [self.gameSession.mazeView bringSubviewToFront:enemy];
    [self.spawnableEnemies addObject:enemy];
  }
}

- (void)spawnFrom:(PNEnemy *)enemy
{
  for (PNEnemy *currentEnemy in self.spawnableEnemies)
  {
    if (currentEnemy.hidden)
    {
      currentEnemy.hidden = NO;
      currentEnemy.tag = enemy.tag;
      
      if (currentEnemy.tag == 1)
      {
        currentEnemy.speed = ENEMY_SPEED / 6;
        currentEnemy.animationImages = [[UIImage imageNamed:@"enemy2"] spritesWiteSize:CGSizeMake(TILE_SIZE, TILE_SIZE)];
      }
      else
      {
        currentEnemy.speed = ENEMY_SPEED;
        currentEnemy.animationImages = [[UIImage imageNamed:@"enemy"] spritesWiteSize:CGSizeMake(TILE_SIZE, TILE_SIZE)];
      }
      [currentEnemy startAnimating];
      [self.spawnableEnemies removeObject:currentEnemy];
      [self.enemies addObject:currentEnemy];
      [UIView animateWithDuration:1.0 animations:^{
        currentEnemy.alpha = 1.0;
      }];
      currentEnemy.frame = enemy.frame;
      break;
    }
  }
}

#pragma mark - Public Functions

- (void)update:(CGFloat)deltaTime
{
  self.enemyTimeAccumulator += deltaTime;
  if (self.enemyTimeAccumulator > 10)
  {
    self.enemyTimeAccumulator = 0;
    NSArray *enemiesArray = self.enemies.count == 0 ? self.spawnableEnemies : self.enemies;
    for (PNEnemy *enemy in enemiesArray)
    {
      if (enemy.wantSpawn)
      {
        enemy.wantSpawn = NO;
    //    [self spawnFrom:enemy];
        break;
      }
    }
  }
  
  for (PNEnemy *enemy in self.enemies)
  {
    [enemy update:deltaTime];
  }
}

@end