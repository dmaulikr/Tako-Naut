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
#import "TNMacros.h"
#import "MXToolBox/MXToolBox.h"
#import <MXAudioManager/MXAudioManager.h>

@interface TNMenuViewController()
@property IBOutlet UILabel *versionLabel;
@property IBOutlet UIButton *gameButton;
@property IBOutlet UIButton *highScoresButton;
@property IBOutlet UIButton *achievementsButton;
@property IBOutlet UIButton *settingsButton;
@property IBOutlet UIButton *aboutButton;
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
  
  //--- setting buttons ---//
  self.gameButton.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.gameButton.layer.borderWidth = 2.0;
  self.highScoresButton.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.highScoresButton.layer.borderWidth = 2.0;
  self.achievementsButton.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.achievementsButton.layer.borderWidth = 2.0;
  self.settingsButton.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.settingsButton.layer.borderWidth = 2.0;
  self.aboutButton.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.aboutButton.layer.borderWidth = 2.0;
  [self refreshAchievementsButton];
  
  [[MXGameCenterManager sharedInstance] authenticateLocalPlayer:^(BOOL isEnabled) {
    //--- actually we don't have achievements ---//
    //[self refreshAchievementsButton];
  }];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.gameButton setTitle:![TNAppDelegate sharedInstance].gameVc ? LOCALIZE(@"takonaut.menu.new_game") : LOCALIZE(@"takonaut.menu.resume_game") forState:UIControlStateNormal];
}

- (void)refreshAchievementsButton
{
  BOOL isEnabled = false;//[MXGameCenterManager sharedInstance].gameCenterEnabled;
  self.achievementsButton.hidden = !isEnabled;
  self.achievementsButtonHeight.constant = isEnabled ? 50 : 0;
  self.achievementsButtonBottomMargin.constant = isEnabled ? 10 : 0;
}

#pragma mark - Actions

- (IBAction)newGameTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  if (![TNAppDelegate sharedInstance].gameVc)
  {
    [[TNAppDelegate sharedInstance] selectScreen:STTutorial];
  }
  else
  {
    [[TNAppDelegate sharedInstance] selectScreen:STResumeGame];
  }
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