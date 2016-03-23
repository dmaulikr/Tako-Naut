//
//  PNGameViewController.m
//  PsyNaut
//
//  Created by mugx on 22/02/16.
//  Copyright (c) 2016 mugx. All rights reserved.
//

#import "PNGameViewController.h"
#import "PNGameSession.h"

@interface PNGameViewController()
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
  [self.gameSession.player didSwipe:sender.direction];
}

#pragma mark - Update Stuff

- (void)refreshUI
{
  self.timeLabel.text = @"Time\n20";
  self.scoreLabel.text = @"Score\n999";
}

- (void)update
{
  CFTimeInterval currentTime = [_displayLink timestamp];
  CFTimeInterval deltaTime;
  deltaTime = currentTime - _previousTimestamp;
  _previousTimestamp = currentTime;

  //--- update game session ---//
  [self.gameSession update:deltaTime];
  
  //--- refreshing ui ---//
  [self refreshUI];
}

@end