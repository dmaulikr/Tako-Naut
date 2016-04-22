//
//  TNEnemy.m
//  Takonaut
//
//  Created by mugx on 23/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "TNEnemy.h"
#import "TNPlayer.h"
#import "TNMacros.h"
#import "TNTile+AI.h"

#define ANIM_TIME 0.5

@interface TNEnemy()
@property(nonatomic,assign) BOOL exploding;
@property(nonatomic,strong) NSMutableArray *path;
@property(nonatomic,assign) float timeAccumulator;
@property(nonatomic,assign) float upatePathAccumulator;
@end

@implementation TNEnemy

- (instancetype)initWithFrame:(CGRect)frame withGameSession:(TNGameSession *)gameSession
{
  self = [super initWithFrame:frame];
  self.gameSession = gameSession;
  self.layer.zPosition = 10;
  self.path = [@[] mutableCopy];
  self.velocity = CGPointMake(0, 0);
  return self;
}

- (void)update:(CGFloat)deltaTime
{
  self.timeAccumulator += deltaTime;
  self.upatePathAccumulator += deltaTime;

  CGRect originalFrame = CGRectMake((int)roundf(self.frame.origin.x / TILE_SIZE) * TILE_SIZE, (int)roundf(self.frame.origin.y / TILE_SIZE) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
  TNPlayer *player = self.gameSession.player;

  if (self.timeAccumulator > 1 || self.path.count == 0)
  {
    self.timeAccumulator = 0;
    NSArray *newPath = [self search:player.frame];
    CGRect firstPathFrame = [self.path.firstObject CGRectValue];
    CGRect firstNewPathFrame = [newPath.firstObject CGRectValue];
    NSUInteger currentSteps = self.path.count;
    NSUInteger newSteps = newPath.count;
    
    BOOL hasToUpdatePath = currentSteps == 0 || currentSteps > newSteps || (distance(originalFrame, firstPathFrame) > distance(originalFrame, firstNewPathFrame));
    if (hasToUpdatePath)
    {
      self.upatePathAccumulator = 0;
      self.path = [NSMutableArray arrayWithArray:newPath];
    }
  }
  
  if (self.path.count > 0)
  {
    CGRect nextFrame = [self.path.firstObject CGRectValue];
    if ([self collidesTarget:originalFrame path:self.path])
    {
      [self.path removeObject:[NSValue valueWithCGRect:originalFrame]];
    }
    
    float speed = self.speed + self.speed * deltaTime;
    CGRect eastFrame = CGRectMake(self.frame.origin.x - speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect westFrame = CGRectMake(self.frame.origin.x  + speed, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect northFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y - speed, self.frame.size.width, self.frame.size.height);
    CGRect southFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y + speed, self.frame.size.width, self.frame.size.height);
    BOOL collidesEast = [self checkWallCollision:eastFrame] != nil;
    BOOL collidesWest = [self checkWallCollision:westFrame] != nil;
    BOOL collidesNorth = [self checkWallCollision:northFrame] != nil;
    BOOL collidesSouth = [self checkWallCollision:southFrame] != nil;
    
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