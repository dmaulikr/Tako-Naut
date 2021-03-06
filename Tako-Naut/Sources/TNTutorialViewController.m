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
@property IBOutlet UIImageView *enemyImage2;
@property IBOutlet UIImageView *playerImage;
@property IBOutlet UIImageView *goalImage;
@property IBOutlet UIImageView *firstArrow;
@property IBOutlet UIImageView *secondArrow;
@property IBOutlet UILabel *hurryupLabel;
@end

@implementation TNTutorialViewController

+ (instancetype)create
{
  return [[TNTutorialViewController alloc] initWithNibName:@"TNTutorialViewController" bundle:nil];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  //--- enemyImage stuff ---//
  self.enemyImage.animationImages = [[UIImage imageNamed:@"enemy"] spritesWiteSize:CGSizeMake(32, 32)];
  self.enemyImage.animationDuration = 0.4f;
  self.enemyImage.animationRepeatCount = 0;
  [self.enemyImage startAnimating];
  
  self.enemyImage2.animationImages = [[UIImage imageNamed:@"enemy2"] spritesWiteSize:CGSizeMake(32, 32)];
  self.enemyImage2.animationDuration = 0.4f;
  self.enemyImage2.animationRepeatCount = 0;
  [self.enemyImage2 startAnimating];
  
  //--- playerImage stuff ---//
  self.playerImage.animationImages = [[UIImage imageNamed:@"player"] spritesWiteSize:CGSizeMake(32, 32)];
  self.playerImage.animationDuration = 0.4f;
  self.playerImage.animationRepeatCount = 0;
  [self.playerImage startAnimating];
  
  //--- goalImage stuff ---//
  self.goalImage.animationImages = @[[UIImage imageNamed:@"gate_open"], [UIImage imageNamed:@"gate_close"]];
  self.goalImage.animationDuration = 1.0f;
  self.goalImage.animationRepeatCount = 0;
  [self.goalImage startAnimating];
  
  //--- arrows stuff ---//
  [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
    self.firstArrow.alpha = 0.4;
  } completion:^(BOOL finished) {
    self.firstArrow.alpha = 1.0;
  }];
  
  [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
    self.secondArrow.alpha = 0.4;
  } completion:^(BOOL finished) {
    self.secondArrow.alpha = 1.0;
  }];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
    self.hurryupLabel.alpha = 0.4;
  } completion:^(BOOL finished) {
    
  }];
}

#pragma mark - IBAction

- (IBAction)newGame:(id)sender
{
  [[TNAppDelegate sharedInstance] selectScreen:STNewGame];
}

@end
