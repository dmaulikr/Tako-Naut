//
//  TNGameViewController.m
//  PsyNaut
//
//  Created by mugx on 22/02/16.
//  Copyright (c) 2016 mugx. All rights reserved.
//

#import "TNGameViewController.h"
#import "TNGameSession.h"
#import "TNConstants.h"
#import "TNMacros.h"
#import <MXAudioManager/MXAudioManager.h>

@interface TNGameViewController() <TNGameSessionDelegate>
@property(nonatomic,strong) TNGameSession *gameSession;
@property(nonatomic,strong) CADisplayLink *displayLink;
@property(nonatomic,assign) CFTimeInterval previousTimestamp;
@property(nonatomic,strong) UISwipeGestureRecognizer *swipeRight;
@property(nonatomic,strong) UISwipeGestureRecognizer *swipeLeft;
@property(nonatomic,strong) UISwipeGestureRecognizer *swipeUp;
@property(nonatomic,strong) UISwipeGestureRecognizer *swipeDown;

// HUD
@property IBOutlet UILabel *timeLabel;
@property IBOutlet UILabel *scoreLabel;
@property IBOutlet UIImageView *firstItem;
@property IBOutlet UIImageView *secondItem;
@property IBOutlet UIImageView *thirdItem;

// game view
@property IBOutlet UIView *gameView;

// game over
@property IBOutlet UIView *gameOverView;
@property IBOutlet UIView *gameOverPanel;
@property IBOutlet UILabel *scoreLabel_inGameOver;
@end

@implementation TNGameViewController

+ (instancetype)create
{
  return [[TNGameViewController alloc] initWithNibName:@"TNGameViewController" bundle:nil];
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  //--- setup game session ---//
  self.gameSession = [[TNGameSession alloc] initWithView:self.gameView];
  self.gameSession.delegate = self;
  [self.gameSession startLevel:1];
  
  //--- setup swipes ---//
  self.swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
  self.swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
  [self.gameView addGestureRecognizer:self.swipeRight];
  
  self.swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
  self.swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
  [self.gameView addGestureRecognizer:self.swipeLeft];
  
  self.swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
  self.swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
  [self.gameView addGestureRecognizer:self.swipeUp];
  
  self.swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
  self.swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
  [self.gameView addGestureRecognizer:self.swipeDown];
  
  //--- setup timer ---//
  self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
  [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
  
  //--- game over view ---//
  self.gameOverView.hidden = YES;
  self.gameOverPanel.layer.borderColor = [MAGENTA_COLOR CGColor];
  self.gameOverPanel.layer.borderWidth = 2.0;
  
  //--- init hud ---//
  [self initHud];
}

#pragma mark - Init Stuff

- (void)initHud
{
  self.firstItem.alpha = 1.0;
  self.secondItem.alpha = 1.0;
  self.thirdItem.alpha = 1.0;
}

#pragma mark - Gesture Recognizer Stuff

- (void)didSwipe:(UISwipeGestureRecognizer *)sender
{
  [self.gameSession didSwipe:sender.direction];
}

#pragma mark - IBActions

- (IBAction)gameOverTouched:(id)sender
{
  [self.gameOverView setHidden:YES];
  [self.gameSession startLevel:1];
  
  //--- setup timer ---//
  self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
  [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - Observer stuff

- (void)didUpdateScore:(NSUInteger)score
{
  self.scoreLabel.text = [NSString stringWithFormat:@"Score\n%ld", (unsigned long)score];
}

- (void)didUpdateTime:(NSUInteger)time
{
  self.timeLabel.text = [NSString stringWithFormat:@"Time\n%ld", (unsigned long)time];
}

- (void)didGotLife:(NSUInteger)livesCount
{
  self.firstItem.alpha = livesCount == 0 ? 0.2 : 1.0;
  self.secondItem.alpha = livesCount <= 1 ? 0.2 : 1.0;
  self.thirdItem.alpha = livesCount <= 2 ? 0.2 : 1.0;
}

- (void)didNextLevel:(NSUInteger)levelCount
{
  [self initHud];
}

- (void)didGameOver:(TNGameSession *)session
{
  [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
  
  [self.view bringSubviewToFront:self.gameOverView];
  [self.gameOverView setHidden:NO];
  self.gameOverView.alpha = 0.0f;
  self.scoreLabel_inGameOver.text = self.scoreLabel.text;
  
  [UIView animateWithDuration:0.5f animations:^{
    self.gameOverView.alpha = 1.0f;
  } completion:^(BOOL finished) {
//    [TNHighScoresViewController saveScore:session.currentScore];
  }];
}

#pragma mark - Update Stuff

- (void)update
{
  CFTimeInterval currentTime = [_displayLink timestamp];
  CFTimeInterval deltaTime;
  deltaTime = currentTime - _previousTimestamp;  
  _previousTimestamp = currentTime;
  deltaTime = deltaTime < 0.1 ? deltaTime : 0.015;

  //--- update game session ---//
  [self.gameSession update:deltaTime];
}

@end