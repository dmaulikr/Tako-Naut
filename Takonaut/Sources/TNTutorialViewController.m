//
//  TNTutorialViewController.m
//  Takonaut
//
//  Created by mugx on 19/04/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "TNTutorialViewController.h"
#import "MXToolBox/MXToolBox.h"
#import "TNMacros.h"
#import "TNAppDelegate.h"

@interface TNTutorialViewController ()
@property IBOutlet UIImageView *enemyImage;
@property IBOutlet UIImageView *swipeImage;
@property IBOutlet UIImageView *playerImage;
@property IBOutlet UIImageView *goalImage;
@property IBOutlet UILabel *hurryupLabel;
@end

@implementation TNTutorialViewController

+ (instancetype)create
{
  return [[TNTutorialViewController alloc] initWithNibName:@"TNTutorialViewController" bundle:nil];
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  //--- enemyImage stuff ---//
  self.enemyImage.animationImages = [[UIImage imageNamed:@"enemy"] spritesWiteSize:CGSizeMake(32, 32)];
  self.enemyImage.animationDuration = 0.4f;
  self.enemyImage.animationRepeatCount = 0;
  [self.enemyImage startAnimating];
  
  //--- playerImage stuff ---//
  self.playerImage.animationImages = [[UIImage imageNamed:@"player"] spritesWiteSize:CGSizeMake(32, 32)];
  self.playerImage.animationDuration = 0.4f;
  self.playerImage.animationRepeatCount = 0;
  [self.playerImage startAnimating];
  
  //--- goalImage stuff ---//
  self.goalImage.animationImages = @[[[UIImage imageNamed:@"gate_open"] imageColored:CYAN_COLOR], [[UIImage imageNamed:@"gate_close"] imageColored:CYAN_COLOR]];
  self.goalImage.animationDuration = 1.0f;
  self.goalImage.animationRepeatCount = 0;
  [self.goalImage startAnimating];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
    self.hurryupLabel.alpha = 0.4;
  } completion:^(BOOL finished) {
    
  }];
  
  [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
    self.swipeImage.transform = CGAffineTransformTranslate(self.hurryupLabel.transform, 80, 0);
  } completion:^(BOOL finished) {
    
  }];
}

#pragma mark - IBAction

- (IBAction)newGame:(id)sender
{
  [[TNAppDelegate sharedInstance] selectScreen:STNewGame];
}

@end
