//
//  PNMenuViewController.m
//  Psynaut
//
//  Created by mugx on 15/05/14.
//  Copyright (c) 2014 mugx. All rights reserved.
//

#import "PNMenuViewController.h"
#import "PNAppDelegate.h"
#import "PNConstants.h"
#import "MXToolBox/MXToolBox.h"
#import <MXAudioManager/MXAudioManager.h>

@interface PNMenuViewController()
@property IBOutlet UILabel *versionLabel;
@property IBOutlet UIButton *achievementsButton;
@property IBOutlet NSLayoutConstraint *achievementsButtonHeight;
@property IBOutlet NSLayoutConstraint *achievementsButtonBottomMargin;
@end

@implementation PNMenuViewController

+ (instancetype)create
{
  PNMenuViewController *menuViewController = [[PNMenuViewController alloc] initWithNibName:nil bundle:nil];
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
  [[MXAudioManager sharedInstance] play:STStartgame];
  [[PNAppDelegate sharedInstance] selectScreen:STNewGame];
}

- (IBAction)highScoresTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  [[PNAppDelegate sharedInstance] selectScreen:STHighScores];
}

- (IBAction)achievementsTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  [[PNAppDelegate sharedInstance] selectScreen:STAchievements];
}

- (IBAction)settingsTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  [[PNAppDelegate sharedInstance] selectScreen:STSettings];
}

- (IBAction)aboutTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  [[PNAppDelegate sharedInstance] selectScreen:STCredits];
}

@end