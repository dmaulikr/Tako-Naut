//
//  TNSettingsViewController.m
//  Tako-Naut
//
//  Created by mugx on 25/04/15.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "TNSettingsViewController.h"
#import "TNAppDelegate.h"
#import "TNMacros.h"
#import "TNConstants.h"
#import "MXToolBox.h"
#import <MXAudioManager/MXAudioManager.h>

typedef NS_ENUM(NSUInteger, VolumeType) {
  VMute = 0,
  VLow = 1,
  VMid = 5,
  VHigh = 10
};

@interface TNSettingsViewController()
@property IBOutlet UIView *languageView;
@property IBOutlet UIView *soundEnabledView;
@property IBOutlet UIView *soundVolumeView;
@property IBOutlet UILabel *settingsTitleLabel;
@property IBOutlet UILabel *languageTitleLabel;
@property IBOutlet UILabel *languageValueLabel;
@property IBOutlet UILabel *soundEnabledTitleLabel;
@property IBOutlet UILabel *soundEnabledValueLabel;
@property IBOutlet UIButton *soundEnabledButton;
@property IBOutlet UIButton *volumeButton;
@property IBOutlet UILabel *soundVolumeTitleLabel;
@property IBOutlet UILabel *soundVolumeValueLabel;
@property IBOutlet UIButton *backButton;
@end

@implementation TNSettingsViewController

+ (instancetype)create
{
  return [[TNSettingsViewController alloc] initWithNibName:[[self class] description] bundle:nil];
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  //--- setting buttons ---//
  self.languageView.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.languageView.layer.borderWidth = 2.0;
  
  self.soundEnabledView.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.soundEnabledView.layer.borderWidth = 2.0;
  
  self.soundVolumeView.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.soundVolumeView.layer.borderWidth = 2.0;
  
  self.backButton.layer.borderColor = MAGENTA_COLOR.CGColor;
  self.backButton.layer.borderWidth = 2.0;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self refresh];
}

#pragma mark - Refresh Functions

- (void)refresh
{
  self.settingsTitleLabel.text = LOCALIZE(@"takonaut.menu.settings");
  self.languageTitleLabel.text = LOCALIZE(@"takonaut.settings.language");
  [self.languageValueLabel setText:[[[NSLocale localeWithLocaleIdentifier:[MXLocalizationManager sharedInstance].currentLanguageCode] displayNameForKey:NSLocaleIdentifier value:[MXLocalizationManager sharedInstance].currentLanguageCode] capitalizedString]];
  [self.soundEnabledTitleLabel setText:LOCALIZE(@"takonaut.settings.sound")];
  [self.soundEnabledValueLabel setText:[MXAudioManager sharedInstance].soundEnabled ? LOCALIZE(@"takonaut.settings.enabled") : LOCALIZE(@"takonaut.settings.disabled")];
  [self.soundEnabledButton setSelected:[MXAudioManager sharedInstance].soundEnabled];
  self.soundVolumeTitleLabel.text = LOCALIZE(@"takonaut.settings.volume");
  [self.backButton setTitle:LOCALIZE(@"takonaut.menu.back") forState:UIControlStateNormal];
  [self refreshSoundVolume];
}

- (void)refreshSoundVolume
{
  switch ((int)([MXAudioManager sharedInstance].volume * 10))
  {
    case VMute:
      [self.volumeButton setImage:[UIImage imageNamed:@"iconVolumeMute"] forState:UIControlStateNormal];
      [self.soundVolumeValueLabel setText:LOCALIZE(@"takonaut.settings.volume_mute")];
      break;
    case VLow:
      [self.volumeButton setImage:[UIImage imageNamed:@"iconVolumeLow"] forState:UIControlStateNormal];
      [self.soundVolumeValueLabel setText:LOCALIZE(@"takonaut.settings.volume_low")];
      break;
    case VMid:
      [self.volumeButton setImage:[UIImage imageNamed:@"iconVolumeMid"] forState:UIControlStateNormal];
      [self.soundVolumeValueLabel setText:LOCALIZE(@"takonaut.settings.volume_mid")];
      break;
    case VHigh:
      [self.volumeButton setImage:[UIImage imageNamed:@"iconVolumeHigh"] forState:UIControlStateNormal];
      [self.soundVolumeValueLabel setText:LOCALIZE(@"takonaut.settings.volume_high")];
      break;
  }
}


#pragma mark - IBActions

- (IBAction)languageDecrTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  
  //--- decr logic ---//
  NSArray *langs = [[MXLocalizationManager sharedInstance] availableLanguages];
  for (int i = 0;i < langs.count;++i)
  {
    NSString *currentCode = langs[i];
    if ([currentCode isEqualToString:[[MXLocalizationManager sharedInstance] currentLanguageCode]])
    {
      unsigned long newIndex = (i - 1 + langs.count) % langs.count;
      NSString *newLangCode = langs[newIndex];
      [[MXLocalizationManager sharedInstance] setCurrentLanguageCode:newLangCode];
      break;
    }
  }
  
  [self refresh];
}

- (IBAction)languageIncrTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  
  //--- incr logic ---//
  NSArray *langs = [[MXLocalizationManager sharedInstance] availableLanguages];
  for (int i = 0;i < langs.count;++i)
  {
    NSString *currentCode = langs[i];
    if ([currentCode isEqualToString:[[MXLocalizationManager sharedInstance] currentLanguageCode]])
    {
      unsigned long newIndex = (i + 1) % langs.count;
      NSString *newLangCode = langs[newIndex];
      [[MXLocalizationManager sharedInstance] setCurrentLanguageCode:newLangCode];
      break;
    }
  }
  
  [self refresh];
}

- (IBAction)soundEnabledTouched
{
  [[MXAudioManager sharedInstance] setSoundEnabled:![MXAudioManager sharedInstance].soundEnabled];
  [[MXAudioManager sharedInstance] play:STSelectItem];
  [self refresh];
}

- (IBAction)soundVolumeTouched
{
  switch ((int)([MXAudioManager sharedInstance].volume * 10))
  {
    case VMute:
      [MXAudioManager sharedInstance].volume = (float)VLow / 10;
      [self.volumeButton setImage:[UIImage imageNamed:@"iconVolumeLow"] forState:UIControlStateNormal];
      break;
    case VLow:
      [MXAudioManager sharedInstance].volume = (float)VMid / 10;
      [self.volumeButton setImage:[UIImage imageNamed:@"iconVolumeMid"] forState:UIControlStateNormal];
      break;
    case VMid:
      [MXAudioManager sharedInstance].volume = (float)VHigh / 10;
      [self.volumeButton setImage:[UIImage imageNamed:@"iconVolumeHigh"] forState:UIControlStateNormal];
      break;
    case VHigh:
      [MXAudioManager sharedInstance].volume = (float)VMute / 10;;
      [self.volumeButton setImage:[UIImage imageNamed:@"iconVolumeMute"] forState:UIControlStateNormal];
      break;
  }
  
  [[MXAudioManager sharedInstance] play:STSelectItem];
  [self refresh];
}

- (IBAction)backTouched
{
  [[MXAudioManager sharedInstance] play:STSelectItem];
  [[TNAppDelegate sharedInstance] selectScreen:STMenu];
}

@end