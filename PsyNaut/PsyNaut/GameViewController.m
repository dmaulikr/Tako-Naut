//
//  GameViewController.m
//  PsyNaut
//
//  Created by mugx on 22/02/16.
//  Copyright (c) 2016 mugx. All rights reserved.
//

#import "GameViewController.h"
#import "UIImage+sprite.h"
#import "DEMazeGenerator.h"

#define SPEED 2
#define PLAYER_SIZE 32
#define WALL_SIZE 32
#define MAZ_COL 5
#define MAZ_ROW 5

@interface GameViewController()
@property(nonatomic,strong) UIImageView *player;
@property(nonatomic,strong) DEMazeGenerator *maze;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,strong) NSMutableArray *sceneWalls;
@property(nonatomic,strong) UISwipeGestureRecognizer *gesture1;
@property(nonatomic,strong) UISwipeGestureRecognizer *gesture2;
@property(nonatomic,strong) UISwipeGestureRecognizer *gesture3;
@property(nonatomic,strong) UISwipeGestureRecognizer *gesture4;
@property(nonatomic,assign) UISwipeGestureRecognizerDirection lastDirection;
@property(nonatomic,assign) CGPoint velocity;
@end

@implementation GameViewController

+ (instancetype)create
{
  return [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor blackColor];
  self.sceneWalls = [NSMutableArray array];
  self.maze = [[DEMazeGenerator alloc] initWithRow:MAZ_ROW andCol:MAZ_COL withStartingPoint:CGPointMake(1, 1)];
  self.timer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(update) userInfo:nil repeats:YES];
  
  //--- init gesturee ---//
  self.gesture1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didMovePlayer:)];
  self.gesture1.direction = UISwipeGestureRecognizerDirectionRight;
  [self.view addGestureRecognizer:self.gesture1];
  
  self.gesture2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didMovePlayer:)];
  self.gesture2.direction = UISwipeGestureRecognizerDirectionLeft;
  [self.view addGestureRecognizer:self.gesture2];
  
  self.gesture3 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didMovePlayer:)];
  self.gesture3.direction = UISwipeGestureRecognizerDirectionUp;
  [self.view addGestureRecognizer:self.gesture3];
  
  self.gesture4 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didMovePlayer:)];
  self.gesture4.direction = UISwipeGestureRecognizerDirectionDown;
  [self.view addGestureRecognizer:self.gesture4];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self animateBrain];
  [self renderMaze];
}

- (void)animateBrain
{
  UIImage *spriteSheet = [UIImage imageNamed:@"ZBrain_Walk_LefttoRight"];
  NSArray *arrayWithSprites = [spriteSheet spritesWithSpriteSheetImage:spriteSheet spriteSize:CGSizeMake(64, 64)];
  self.player = [[UIImageView alloc] initWithFrame:CGRectMake(WALL_SIZE, WALL_SIZE, PLAYER_SIZE, PLAYER_SIZE)];
  [self.player setAnimationImages:arrayWithSprites];
  self.player.animationDuration = 1.0f;
  self.player.animationRepeatCount = 0;
  [self.player startAnimating];
  [self.view addSubview:self.player];
}

- (void)renderMaze
{
  [self.maze arrayMaze:^(bool **item) {
    for (int r = 0; r < MAZ_ROW * 2 + 1 ; r++)
    {
      for (int c = 0; c < MAZ_COL * 2 + 1 ; c++)
      {
        if (item[r][c] == 1)
        {
          UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(c * WALL_SIZE, r * WALL_SIZE, WALL_SIZE, WALL_SIZE)];
          label.backgroundColor = [UIColor colorWithRed:255 green:0 blue:255 alpha:1];
          [self.view addSubview:label];
          [self.sceneWalls addObject:label];
        }
      }
    }
  }];
}

- (void)update
{
  CGPoint tempVelocity = self.velocity;
  CGRect newRect = CGRectMake(self.player.frame.origin.x + tempVelocity.x, self.player.frame.origin.y + tempVelocity.y, PLAYER_SIZE, PLAYER_SIZE);

  for (UIView *wall in self.sceneWalls)
  {
    if (CGRectIntersectsRect(wall.frame, newRect))
    {
      // 1. understand which is the component is generating the intersection
      //    1.1. eventually minimize that component
      //
      CGRect testRect_x = CGRectMake(self.player.frame.origin.x + tempVelocity.x, self.player.frame.origin.y, PLAYER_SIZE, PLAYER_SIZE);
      if (CGRectIntersectsRect(wall.frame, testRect_x))
      {
        tempVelocity.x = 0;
      }
      
      CGRect testRect_y = CGRectMake(self.player.frame.origin.x, self.player.frame.origin.y + tempVelocity.y, PLAYER_SIZE, PLAYER_SIZE);
      if (CGRectIntersectsRect(wall.frame, testRect_y))
      {
        tempVelocity.y = 0;
      }
    }
  }
  
  if (tempVelocity.x == 0 && tempVelocity.y == 0)
  {
    self.velocity = tempVelocity;
  }

  CGRect rect = CGRectMake(self.player.frame.origin.x + tempVelocity.x, self.player.frame.origin.y + tempVelocity.y, PLAYER_SIZE, PLAYER_SIZE);
  self.player.frame = rect;
}

- (void)didMovePlayer:(UISwipeGestureRecognizer *)sender
{
  self.lastDirection = sender.direction;
  
  if (sender.direction == UISwipeGestureRecognizerDirectionRight)
  {
    NSLog(@"UISwipeGestureRecognizerDirectionRight");
    self.velocity = CGPointMake(SPEED, self.velocity.y);
  }
  
  if (sender.direction == UISwipeGestureRecognizerDirectionLeft)
  {
    NSLog(@"UISwipeGestureRecognizerDirectionLeft");
    self.velocity = CGPointMake(-SPEED, self.velocity.y);
  }
  
  if (sender.direction == UISwipeGestureRecognizerDirectionUp)
  {
    NSLog(@"UISwipeGestureRecognizerDirectionUp");
    self.velocity = CGPointMake(self.velocity.x, -SPEED);
  }
  
  if (sender.direction == UISwipeGestureRecognizerDirectionDown)
  {
    NSLog(@"UISwipeGestureRecognizerDirectionDown");
    self.velocity = CGPointMake(self.velocity.x, SPEED);
  }
}

@end
