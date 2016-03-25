//
//  PNGameViewController.m
//  PsyNaut
//
//  Created by mugx on 22/02/16.
//  Copyright (c) 2016 mugx. All rights reserved.
//

#import "PNGameViewController.h"
#import "PNGameSession.h"
#import "PNConstants.h"
#import <MXAudioManager/MXAudioManager.h>

@interface PNGameViewController() <PNGameSessionDelegate>
@property(nonatomic,strong) PNGameSession *gameSession;
@property(nonatomic,strong) CADisplayLink *displayLink;
@property(nonatomic,assign) CFTimeInterval previousTimestamp;
@property(nonatomic,strong) UISwipeGestureRecognizer *swipeRight;
@property(nonatomic,strong) UISwipeGestureRecognizer *swipeLeft;
@property(nonatomic,strong) UISwipeGestureRecognizer *swipeUp;
@property(nonatomic,strong) UISwipeGestureRecognizer *swipeDown;
@property(nonatomic,strong) UIView *mazeView;

// HUD
@property IBOutlet UILabel *timeLabel;
@property IBOutlet UILabel *scoreLabel;
@property IBOutlet UILabel *firstCharLabel;
@property IBOutlet UILabel *secondCharLabel;
@property IBOutlet UILabel *thirdCharLabel;
@property IBOutlet UILabel *fourthCharLabel;

// game over
@property IBOutlet UIView *gameOverView;
@property IBOutlet UILabel *scoreLabel_inGameOver;
@end

@implementation PNGameViewController

+ (instancetype)create
{
  return [[PNGameViewController alloc] initWithNibName:@"PNGameViewController" bundle:nil];
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  //--- setip game session ---//
  self.gameSession = [[PNGameSession alloc] initWithView:self.view];
  self.gameSession.delegate = self;
  [self.gameSession startLevel:1];
  
  //--- setup swipes ---//
  self.swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
  self.swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
  [self.view addGestureRecognizer:self.swipeRight];
  
  self.swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
  self.swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
  [self.view addGestureRecognizer:self.swipeLeft];
  
  self.swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
  self.swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
  [self.view addGestureRecognizer:self.swipeUp];
  
  self.swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
  self.swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
  [self.view addGestureRecognizer:self.swipeDown];
  
  //--- setup timer ---//
  self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
  [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
  
  //--- game over view ---//
  self.gameOverView.hidden = YES;
}

#pragma mark - Init Stuff

- (void)initHud
{
  self.firstCharLabel.text = [@(arc4random() % 10) description];
  self.secondCharLabel.text = [@(arc4random() % 10) description];
  self.thirdCharLabel.text = [@(arc4random() % 10) description];
  self.fourthCharLabel.text = [@(arc4random() % 10) description];
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

- (void)didGameOver:(PNGameSession *)session
{
  [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
  [[MXAudioManager sharedInstance] play:STGameOver];
  
  [self.view bringSubviewToFront:self.gameOverView];
  [self.gameOverView setHidden:NO];
  self.gameOverView.alpha = 0.0f;
  self.scoreLabel_inGameOver.text = self.scoreLabel.text;
  
  [UIView animateWithDuration:1.0f animations:^{
    self.gameOverView.alpha = 1.0f;
  } completion:^(BOOL finished) {
//    [CYHighScoresViewController saveScore:session.currentScore];
  }];
}

#pragma mark - Update Stuff

- (void)refreshUI
{
  self.timeLabel.text = [NSString stringWithFormat:@"Time\n%d", (int)roundf(self.gameSession.currentTime)];
  self.scoreLabel.text = [NSString stringWithFormat:@"Score\n%d", (int)self.gameSession.currentScore];
}

- (void)update
{
  CFTimeInterval currentTime = [_displayLink timestamp];
  CFTimeInterval deltaTime;
  deltaTime = currentTime - _previousTimestamp;  
  _previousTimestamp = currentTime;
  deltaTime = deltaTime < 0.1 ? deltaTime : 0.015;

  //--- update game session ---//
  [self.gameSession update:deltaTime];
  
  //--- refreshing ui ---//
  [self refreshUI];
}

@end