//
//  GameViewController.m
//  PsyNaut
//
//  Created by mugx on 22/02/16.
//  Copyright (c) 2016 mugx. All rights reserved.
//

#import "GameViewController.h"
#import "UIImage+sprite.h"
#import "MXMazeGenerator.h"

#define SPEED 2
#define TILE_SIZE 32

@interface GameViewController() <UIGestureRecognizerDelegate>
@property(nonatomic,strong) UIImageView *player;
@property(nonatomic,strong) MXMazeGenerator *maze;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,strong) NSMutableArray *sceneWalls;
@property(nonatomic,strong) UISwipeGestureRecognizer *gesture1;
@property(nonatomic,strong) UISwipeGestureRecognizer *gesture2;
@property(nonatomic,strong) UISwipeGestureRecognizer *gesture3;
@property(nonatomic,strong) UISwipeGestureRecognizer *gesture4;
@property(nonatomic,assign) UISwipeGestureRecognizerDirection lastDirection;
@property(nonatomic,assign) CGPoint velocity;
@property(nonatomic,assign) NSUInteger tileWidth;
@property(nonatomic,assign) NSUInteger tileHeight;
@property(nonatomic,assign) NSUInteger row;
@property(nonatomic,assign) NSUInteger col;
@property(nonatomic,strong) UIView *mazeView;
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
  
  int width = [UIScreen mainScreen].bounds.size.width;
  int height = [UIScreen mainScreen].bounds.size.height;
  self.tileWidth = TILE_SIZE;
  self.tileHeight = TILE_SIZE;
  self.col = width / self.tileWidth;
  self.row = height / self.tileHeight;
  
  self.maze = [[MXMazeGenerator alloc] initWithRow:self.row andCol:self.col withStartingPoint:CGPointMake(1, 1)];
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
  
  self.player.userInteractionEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  self.mazeView = [[UIView alloc] initWithFrame:self.view.frame];
  [self.view addSubview:self.mazeView];

  [self animateBrain];
  [self renderMaze];
}

- (void)animateBrain
{
  UIImage *spriteSheet = [UIImage imageNamed:@"octopus"];
  NSArray *arrayWithSprites = [spriteSheet spritesWithSpriteSheetImage:spriteSheet spriteSize:CGSizeMake(64, 64)];
  self.player = [[UIImageView alloc] initWithFrame:CGRectMake(self.tileWidth, self.tileHeight, self.tileWidth, self.tileHeight)];
  [self.player setAnimationImages:arrayWithSprites];
  self.player.animationDuration = 0.2f;
  self.player.animationRepeatCount = 0;
  [self.player startAnimating];
  [self.mazeView addSubview:self.player];
}

- (void)renderMaze
{
  [self.maze arrayMaze:^(bool **item) {
    for (int r = 0; r < self.row * 2 + 1 ; r++)
    {
      for (int c = 0; c < self.col * 2 + 1 ; c++)
      {
        if (item[r][c] == 1)
        {
          UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
          label.backgroundColor = [UIColor colorWithRed:255 green:0 blue:255 alpha:1];
          [self.mazeView addSubview:label];
          [self.sceneWalls addObject:label];
        }
      }
    }
  }];
}

- (void)update
{
  CGPoint tempVelocity = self.velocity;
  CGRect newRect = CGRectMake(self.player.frame.origin.x + tempVelocity.x, self.player.frame.origin.y + tempVelocity.y, self.tileWidth, self.tileHeight);
  
  for (UIView *wall in self.sceneWalls)
  {
    if (CGRectIntersectsRect(wall.frame, newRect))
    {
      CGRect testRect_x = CGRectMake(self.player.frame.origin.x + tempVelocity.x, self.player.frame.origin.y, self.tileWidth, self.tileHeight);
      if (CGRectIntersectsRect(wall.frame, testRect_x))
      {
        tempVelocity.x = 0;
      }
      
      CGRect testRect_y = CGRectMake(self.player.frame.origin.x, self.player.frame.origin.y + tempVelocity.y, self.tileWidth, self.tileHeight);
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
  
  CGRect rect = CGRectMake(self.player.frame.origin.x + tempVelocity.x, self.player.frame.origin.y + tempVelocity.y, self.tileWidth, self.tileHeight);
  self.player.frame = rect;
  
  self.mazeView.frame = CGRectMake(self.mazeView.frame.size.width / 2 -self.player.frame.origin.x, self.mazeView.frame.size.height / 2 -self.player.frame.origin.y, self.mazeView.frame.size.width, self.mazeView.frame.size.height);
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
  return YES;
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
