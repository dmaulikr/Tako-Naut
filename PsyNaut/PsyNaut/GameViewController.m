//
//  GameViewController.m
//  PsyNaut
//
//  Created by mugx on 22/02/16.
//  Copyright (c) 2016 mugx. All rights reserved.
//

#import "GameViewController.h"
#import "GameSession.h"
#import "UIImage+sprite.h"
#import "MXMazeGenerator.h"
#import <MediaPlayer/MediaPlayer.h>

#define SPEED 2
#define TILE_SIZE 32
#define STARTING_X 1
#define STARTING_Y 1

@interface GameViewController()

@property(nonatomic,strong) UIImageView *player;
@property(nonatomic,strong) MXMazeGenerator *mazeGenerator;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,strong) NSMutableArray *sceneWalls;
@property(nonatomic,strong) UISwipeGestureRecognizer *gesture1;
@property(nonatomic,strong) UISwipeGestureRecognizer *gesture2;
@property(nonatomic,strong) UISwipeGestureRecognizer *gesture3;
@property(nonatomic,strong) UISwipeGestureRecognizer *gesture4;
@property(nonatomic,assign) CGPoint velocity;
@property(nonatomic,assign) NSUInteger tileWidth;
@property(nonatomic,assign) NSUInteger tileHeight;
@property(nonatomic,assign) NSUInteger row;
@property(nonatomic,assign) NSUInteger col;
@property(nonatomic,strong) UIView *mazeView;

// HUD
@property IBOutlet UILabel *timeLabel;
@property IBOutlet UILabel *scoreLabel;
@property IBOutlet UILabel *firstCharLabel;
@property IBOutlet UILabel *secondCharLabel;
@property IBOutlet UILabel *thirdCharLabel;
@property IBOutlet UILabel *fourthCharLabel;
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
  
  self.sceneWalls = [NSMutableArray array];
  
  //--- setup maze ---//
  self.tileWidth = TILE_SIZE;
  self.tileHeight = TILE_SIZE;
  self.col = 15;
  self.row = 15;
  self.mazeGenerator = [[MXMazeGenerator alloc] initWithRow:self.row col:self.col startingPosition:CGPointMake(STARTING_X, STARTING_Y)];
  
  //--- setup gestures ---//
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
  
  //--- setup timer ---//
  self.timer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(update) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  self.mazeView = [[UIView alloc] initWithFrame:self.view.frame];
  [self.view addSubview:self.mazeView];
  [self.view sendSubviewToBack:self.mazeView];
  
  [self initHud];
  [self initMaze];
  [self initPlayer];
  [self initOpponent];
}

#pragma mark - Init Stuff

- (void)initMaze
{
  [self.mazeGenerator calculateMaze:^(MazeTyleType **maze)
   {
     for (int r = 0; r < self.row ; r++)
     {
       for (int c = 0; c < self.col; c++)
       {
         if (maze[r][c] == MTWall)
         {
           UIImageView *wall = [[UIImageView alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
           [wall setImage:[UIImage imageNamed:@"wall"]];
           [self.mazeView addSubview:wall];
           [self.sceneWalls addObject:wall];
           [self.mazeView sendSubviewToBack:wall];
         }
         else if (maze[r][c] == MTStart)
         {
           UIImageView *wall = [[UIImageView alloc] initWithFrame:CGRectMake(c * self.tileWidth, r * self.tileHeight, self.tileWidth, self.tileHeight)];
           wall.backgroundColor = [UIColor redColor];
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
  NSArray *arrayWithSprites = [spriteSheet spritesWithSpriteSheetImage:spriteSheet spriteSize:CGSizeMake(64, 64)];
  self.player = [[UIImageView alloc] initWithFrame:CGRectMake(STARTING_Y * self.tileWidth, STARTING_X * self.tileHeight, self.tileWidth, self.tileHeight)];
  [self.player setAnimationImages:arrayWithSprites];
  self.player.animationDuration = 0.2f;
  self.player.animationRepeatCount = 0;
  [self.player startAnimating];
  [self.mazeView addSubview:self.player];
  [self.mazeView bringSubviewToFront:self.player];
}

- (void)initOpponent
{
  
}

- (void)initHud
{
  self.firstCharLabel.text = [@(arc4random() % 10) description];
  self.secondCharLabel.text = [@(arc4random() % 10) description];
  self.thirdCharLabel.text = [@(arc4random() % 10) description];
  self.fourthCharLabel.text = [@(arc4random() % 10) description];
}

#pragma mark - Update Stuff
- (void)refreshUI
{
  self.timeLabel.text = @"Time\n20";
  self.scoreLabel.text = @"Score\n999";
}

- (void)checkCollisionFor:(CGPoint)velocity collideX:(BOOL *)collideX collideY:(BOOL *)collideY
{
  CGRect playerFrame = CGRectMake(self.player.frame.origin.x + velocity.x, self.player.frame.origin.y + velocity.y, self.tileWidth, self.tileHeight);
  for (UIView *wall in self.sceneWalls)
  {
    if (CGRectIntersectsRect(wall.frame, playerFrame))
    {
      CGRect testRect_x = CGRectMake(self.player.frame.origin.x + velocity.x, self.player.frame.origin.y, self.tileWidth, self.tileHeight);
      if (CGRectIntersectsRect(wall.frame, testRect_x))
      {
        *collideX = YES;
      }
      
      CGRect testRect_y = CGRectMake(self.player.frame.origin.x, self.player.frame.origin.y + velocity.y, self.tileWidth, self.tileHeight);
      if (CGRectIntersectsRect(wall.frame, testRect_y))
      {
        *collideY = YES;
      }
    }
  }
}

- (void)update
{
  CGPoint tempVelocity = self.velocity;
  BOOL collideX;
  BOOL collideY;
  [self checkCollisionFor:CGPointMake(tempVelocity.x, tempVelocity.y) collideX:&collideX collideY:&collideY];
  
  if (collideX)
  {
    tempVelocity.x = 0;
  }
  
  if (collideY)
  {
    tempVelocity.y = 0;
  }
  
  if (tempVelocity.x == 0 && tempVelocity.y == 0)
  {
    self.velocity = CGPointMake(0, 0);
  }
  
  //--- updating player frame ---//
  self.player.frame = CGRectMake(self.player.frame.origin.x + tempVelocity.x, self.player.frame.origin.y + tempVelocity.y, self.tileWidth, self.tileHeight);
  
  //--- updating maze frame ---//
  self.mazeView.frame = CGRectMake(self.mazeView.frame.size.width / 2 -self.player.frame.origin.x, self.mazeView.frame.size.height / 2 -self.player.frame.origin.y, self.mazeView.frame.size.width, self.mazeView.frame.size.height);
  
  //--- refreshing ui ---//
  [self refreshUI];
}

#pragma mark - Gesture Recognizer Stuff

- (void)didMovePlayer:(UISwipeGestureRecognizer *)sender
{
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
