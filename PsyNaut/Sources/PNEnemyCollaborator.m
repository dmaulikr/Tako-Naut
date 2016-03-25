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

#define ENEMY_SPEED 1
#define ENEMY_PADDING 0.5

@interface PNEnemyCollaborator()
@property(nonatomic,weak) PNGameSession *gameSession;
@property(nonatomic,assign) float enemyTimeAccumulator;
@property(nonatomic,strong,readwrite) NSMutableArray *enemies;
@end

@implementation PNEnemyCollaborator

- (instancetype)init:(PNGameSession *)gameSession
{
  self = [super init];
  _gameSession = gameSession;
  _enemies = [NSMutableArray array];
  return self;
}

- (void)spawnEnemy
{
  PNEnemy *enemy = [[PNEnemy alloc] initWithFrame:CGRectMake(STARTING.y * TILE_SIZE + ENEMY_PADDING, STARTING.x * TILE_SIZE + ENEMY_PADDING, TILE_SIZE - ENEMY_SPEED, TILE_SIZE - ENEMY_SPEED) withGameSession:self.gameSession];
  enemy.animationImages = [[UIImage imageNamed:@"enemy"] spritesWiteSize:CGSizeMake(TILE_SIZE, TILE_SIZE)];
  enemy.animationDuration = 0.4f;
  enemy.animationRepeatCount = 0;
  [enemy startAnimating];
  enemy.alpha = 0.0;
  [self.gameSession.mazeView addSubview:enemy];
  [self.gameSession.mazeView bringSubviewToFront:enemy];
  [self.enemies addObject:enemy];
  
  [UIView animateWithDuration:1.0 animations:^{
    enemy.alpha = 1.0;
  }];
}

- (void)update:(CGFloat)deltaTime
{
  self.enemyTimeAccumulator += deltaTime;
  if (self.enemyTimeAccumulator > 3)
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
      [self spawnEnemy];
    }
  }
  
  for (PNEnemy *enemy in self.enemies)
  {
    [enemy update:deltaTime];
  }
}

@end