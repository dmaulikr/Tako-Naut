//
//  TNMenuViewController.m
//  Takonaut
//
//  Created by mugx on 15/05/14.
//  Copyright (c) 2014 mugx. All rights reserved.
//

#import "TNMenuViewController.h"
#import "TNAppDelegate.h"
#import "TNConstants.h"
#import "MXToolBox/MXToolBox.h"
#import <MXAudioManager/MXAudioManager.h>

@interface TNMenuViewController()
@property IBOutlet UILabel *versionLabel;
@property IBOutlet UIButton *achievementsButton;
@property IBOutlet NSLayoutConstraint *achievementsButtonHeight;
@property IBOutlet NSLayoutConstraint *achievementsButtonBottomMargin;
@end

@implementation TNMenuViewController

+ (instancetype)create
{
  TNMenuViewController *menuViewController = [[TNMenuViewController alloc] initWithNibName:nil bundle:nil];
  return menuViewController;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.versionLabel.text = [NSString stringWithFormat:@"v%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
  [self refreshAchievementsButton];
  /*
  [[MXGameCenterManager sharedInstance] authenticateLocalPlayer:^(BOOL isEnabled) {
    [self refreshAchievementsButton];
  }];
   */
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

- (void)refreshAchievementsButton
{
  BOOL isEnabled = [MXGameCenterManager sharedInstance].gameCenterEnabled;
  self.achievementsButton.hidden = !isEnabled;
  self.achievementsButtonHeight.constant = isEnabled ? 50 : 0;
  self.achievementsButtonBottomMargin.constant = isEnabled ? 10 : 0;
}

#pragma mark - Actions

- (IBAction)newGameTouched
{
  //[[TNAppDelegate sharedInstance] selectScreen:STNewGame];
  [[TNAppDelegate sharedInstance] selectScreen:STTutorial];
}

- (IBAction)highScoresTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  [[TNAppDelegate sharedInstance] selectScreen:STHighScores];
}

- (IBAction)achievementsTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  [[TNAppDelegate sharedInstance] selectScreen:STAchievements];
}

- (IBAction)settingsTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  [[TNAppDelegate sharedInstance] selectScreen:STSettings];
}

- (IBAction)aboutTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  [[TNAppDelegate sharedInstance] selectScreen:STCredits];
}

@end