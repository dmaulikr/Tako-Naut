//
//  PNEnemy.m
//  Psynaut
//
//  Created by mugx on 23/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNEnemy.h"
#import "PNPlayer.h"
#import "PNMacros.h"
#import "PNTile+AI.h"

#define ANIM_TIME 0.5

@interface PNEnemy()
@property(nonatomic,assign) BOOL exploding;
@property(nonatomic,strong) NSMutableArray *path;
@property(nonatomic,assign) float timeAccumulator;
@end

@implementation PNEnemy

- (instancetype)initWithFrame:(CGRect)frame withGameSession:(PNGameSession *)gameSession
{
  self = [super initWithFrame:frame];
  self.gameSession = gameSession;
  self.speed = ENEMY_SPEED;
  self.velocity = CGPointMake(0, 0);
  return self;
}

- (void)update:(CGFloat)deltaTime
{
  self.timeAccumulator += deltaTime;
  if (self.timeAccumulator > 3 || !self.path || self.path.count == 0)
  {
    self.timeAccumulator = 0;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      PNPlayer *player = self.gameSession.player;
      NSArray *newPath = [self search:player.frame];
      if (!self.path || self.path.count == 0 || (self.velocity.x == 0 && self.velocity.y == 0) || newPath.count < self.path.count)
      {
        self.path = [NSMutableArray arrayWithArray:newPath];
      }
    });
  }
  
  if (self.path.count > 0)
  {
    CGRect originalFrame = CGRectMake((int)roundf(self.frame.origin.x / TILE_SIZE) * TILE_SIZE, (int)roundf(self.frame.origin.y / TILE_SIZE) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
    CGRect nextFrame = [self.path.firstObject CGRectValue];
    if ([self collidesTarget:originalFrame cells:self.path])
    {
      [self.path removeObject:[NSValue valueWithCGRect:originalFrame]];
    }
    
    float speed = self.speed + self.speed * deltaTime;
    CGRect eastFrame = CGRectMake(self.frame.origin.x - speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect westFrame = CGRectMake(self.frame.origin.x  + speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect northFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y - speed, self.frame.size.width, self.frame.size.height);
    CGRect southFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y + speed, self.frame.size.width, self.frame.size.height);
    BOOL collidesEast = [self checkWallCollision:eastFrame];
    BOOL collidesWest = [self checkWallCollision:westFrame];
    BOOL collidesNorth = [self checkWallCollision:northFrame];
    BOOL collidesSouth = [self checkWallCollision:southFrame];
    
    NSMutableArray *possibleDirections = [NSMutableArray array];
    if (!collidesEast) [possibleDirections addObject:@{@"move":@('e'), @"frame":[NSValue valueWithCGRect:eastFrame]}];
    if (!collidesWest) [possibleDirections addObject:@{@"move":@('w'), @"frame":[NSValue valueWithCGRect:westFrame]}];
    if (!collidesNorth) [possibleDirections addObject:@{@"move":@('n'), @"frame":[NSValue valueWithCGRect:northFrame]}];
    if (!collidesSouth) [possibleDirections addObject:@{@"move":@('s'), @"frame":[NSValue valueWithCGRect:southFrame]}];
    switch ([self getBestDirection:possibleDirections targetFrame:nextFrame])
    {
      case 'e':
        [self didSwipe:UISwipeGestureRecognizerDirectionLeft];
        break;
      case 'w':
        [self didSwipe:UISwipeGestureRecognizerDirectionRight];
        break;
      case 'n':
        [self didSwipe:UISwipeGestureRecognizerDirectionUp];
        break;
      case 's':
        [self didSwipe:UISwipeGestureRecognizerDirectionDown];
        break;
    }
  }
  [super update:deltaTime];
}

@end