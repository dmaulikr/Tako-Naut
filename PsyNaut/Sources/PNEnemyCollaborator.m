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

#define MAX_ENEMIES 300

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

- (void)update:(CGFloat)deltaTime
{
  self.enemyTimeAccumulator += deltaTime;
  if (self.enemyTimeAccumulator > 2)
  {
    self.enemyTimeAccumulator = 0;
    
    CGRect initFrame = CGRectMake(STARTING.y * TILE_SIZE + ENEMY_PADDING, STARTING.x * TILE_SIZE + ENEMY_PADDING, TILE_SIZE - ENEMY_SPEED, TILE_SIZE - ENEMY_SPEED);
    bool canRespawn = true;
    for (PNEnemy *enemy in self.enemies)
    {
      int manhattanDistance = abs((int)(enemy.frame.origin.x - initFrame.origin.x)) + abs((int)(enemy.frame.origin.y - initFrame.origin.y));
      if (manhattanDistance < TILE_SIZE * 2)
      {
        canRespawn = false;
        break;
      }
    }
    
    if (canRespawn)
    {
      [self _spawnEnemy];
    }
  }
  
  for (PNEnemy *enemy in self.enemies)
  {
    [enemy update:deltaTime];
  }
}

#pragma mark - Private Functions

- (void)_initEnemies
{
  self.enemies = [NSMutableArray array];
  self.spawnableEnemies = [NSMutableArray array];
  for (int i = 0;i < MAX_ENEMIES;++i)
  {
    PNEnemy *enemy = [[PNEnemy alloc] initWithFrame:CGRectMake(STARTING.y * TILE_SIZE + ENEMY_PADDING, STARTING.x * TILE_SIZE + ENEMY_PADDING, TILE_SIZE - ENEMY_SPEED, TILE_SIZE - ENEMY_SPEED) withGameSession:self.gameSession];
    enemy.animationDuration = 0.4f;
    enemy.animationRepeatCount = 0;
    enemy.alpha = 0.0;
    enemy.hidden = YES;
    [self.gameSession.mazeView addSubview:enemy];
    [self.gameSession.mazeView bringSubviewToFront:enemy];
    [self.spawnableEnemies addObject:enemy];
  }
}

- (void)_spawnEnemy
{
  for (PNEnemy *enemy in self.spawnableEnemies)
  {
    if (enemy.hidden)
    {
      enemy.hidden = NO;
      enemy.tag = (arc4random() % 100) < 80 ? 0 : 1;
      if (enemy.tag == 1 || !self.medusaWasOut)
      {
        self.medusaWasOut = YES;
        enemy.speed = ENEMY_SPEED / 4;
        enemy.animationImages = [[UIImage imageNamed:@"enemy2"] spritesWiteSize:CGSizeMake(TILE_SIZE, TILE_SIZE)];
      }
      else
      {
        enemy.speed = ENEMY_SPEED;
        enemy.animationImages = [[UIImage imageNamed:@"enemy"] spritesWiteSize:CGSizeMake(TILE_SIZE, TILE_SIZE)];
      }
      [enemy startAnimating];
      [self.spawnableEnemies removeObject:enemy];
      [self.enemies addObject:enemy];
      [UIView animateWithDuration:1.0 animations:^{
        enemy.alpha = 1.0;
      }];
      break;
    }
  }
}


@end