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
@property IBOutlet UILabel *currentLivesLabel;

// game view
@property IBOutlet UIView *gameView;

// game over
@property IBOutlet UIView *gameOverView;
@property IBOutlet UIView *gameOverPanel;
@property IBOutlet UILabel *scoreLabel_inGameOver;

// current level
@property IBOutlet UIView *currentLevelPanel;
@property IBOutlet UILabel *currentLevelLabel;

// hurry up label
@property IBOutlet UILabel *hurryUpLabel;
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

  //--- setup current level stuff ---//
  self.currentLevelPanel.hidden = YES;
  self.currentLevelPanel.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.currentLevelPanel.layer.borderWidth = 2.0;
  
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
  
  //--- game over view ---//
  self.gameOverView.hidden = YES;
  self.gameOverPanel.layer.borderColor = [MAGENTA_COLOR CGColor];
  self.gameOverPanel.layer.borderWidth = 2.0;
  
  //--- setup timer ---//
  self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
  [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
  
  self.view.alpha = 0;
  [UIView animateWithDuration:0.5 animations:^{
    self.view.alpha = 1;
  }completion:^(BOOL finished) {
    //--- setup game session ---//
    self.gameSession = [[TNGameSession alloc] initWithView:self.gameView];
    self.gameSession.delegate = self;
    [self.gameSession startLevel:1];
  }];
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
  self.hurryUpLabel.hidden = YES;
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

- (void)didUpdateLives:(NSUInteger)livesCount
{
  self.currentLivesLabel.text = [NSString stringWithFormat:@"x%lu", (unsigned long)livesCount];
}

- (void)didUpdateLevel:(NSUInteger)levelCount
{
  self.hurryUpLabel.hidden = YES;
  self.currentLevelPanel.hidden = NO;
  self.currentLevelPanel.alpha = 0;
  self.currentLevelLabel.text = [NSString stringWithFormat:@"Level %lu", (unsigned long)levelCount];
  [UIView animateWithDuration:0.2 animations:^{
    self.currentLevelPanel.alpha = 1;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.2 delay:0.5 options:0 animations:^{
      self.currentLevelPanel.alpha = 0;
    } completion:^(BOOL finished) {
      self.currentLevelPanel.hidden = YES;
    }];
  }];
}

- (void)didHurryUp
{
  if (self.hurryUpLabel.hidden)
  {
    self.hurryUpLabel.hidden = NO;
    self.hurryUpLabel.alpha = 0;
    
    [UIView animateWithDuration:0.1 animations:^{
      self.hurryUpLabel.alpha = 1;
    } completion:^(BOOL finished) {
      [[MXAudioManager sharedInstance] play:STTimeOver];
      
      // Add the animation
      CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
      [animation setFromValue:[NSNumber numberWithFloat:1.0]];
      [animation setToValue:[NSNumber numberWithFloat:0.5]];
      [animation setAutoreverses:YES];
      [animation setRepeatCount:HUGE_VALF];
      [animation setDuration:0.15f];
      [self.hurryUpLabel.layer addAnimation:animation forKey:@"opacity"];
    }];
  }
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