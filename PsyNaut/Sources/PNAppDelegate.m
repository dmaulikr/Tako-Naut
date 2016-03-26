//
//  PNAppDelegate.m
//  PsyNaut
//
//  Created by mugx on 22/02/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNAppDelegate.h"
#import "PNGameViewController.h"
#import "PNMenuViewController.h"
#import "MXToolBox.h"
#import "PNMacros.h"
#import <MXAudioManager/MXAudioManager.h>

@interface PNAppDelegate ()

@end

@implementation PNAppDelegate

int main(int argc, char * argv[]) { @autoreleasepool { return UIApplicationMain(argc, argv, nil, NSStringFromClass([PNAppDelegate class])); } }

+ (PNAppDelegate *)sharedInstance
{
  return (PNAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window.rootViewController = [PNMenuViewController create];
  [self.window makeKeyAndVisible];
  [self prepareSounds];
  return YES;
}

- (void)prepareSounds
{
  [MXAudioManager sharedInstance].soundEnabled = SOUND_ENABLED;
  [MXAudioManager sharedInstance].volume = SOUND_DEFAULT_VOLUME;
  [[MXAudioManager sharedInstance] load:[MXUtils jsonFromFile:@"gameConfiguration.json"]];
}

#pragma mark - Select Screen

- (void)selectScreen:(ScreenType)screenType
{
  switch (screenType) {
    case STMenu:
      [self transitionToViewController:[PNMenuViewController create]];
      break;
    case STNewGame:
      [self transitionToViewController:[PNGameViewController create]];
      break;
    case STHighScores:
      if ([[MXGameCenterManager sharedInstance] gameCenterEnabled])
      {
        [[MXGameCenterManager sharedInstance] showLeaderboard];
      }
      else
      {
//        [self transitionToViewController:[CYHighScoresViewController create]];
      }
      break;
    case STAchievements:
      if ([[MXGameCenterManager sharedInstance] gameCenterEnabled])
      {
        [[MXGameCenterManager sharedInstance] showAchievements];
      }
      else
      {
        [[MXGameCenterManager sharedInstance] authenticateLocalPlayer:^(BOOL isEnabled) {
          [[MXGameCenterManager sharedInstance] showAchievements];
        }];
      }
      break;
    case STSettings:
      //[self transitionToViewController:[CYSettingsViewController create]];
      break;
    case STCredits:
      //[self transitionToViewController:[CYCreditsViewController create]];
      break;
    default:
      break;
  }
}

- (void)transitionToViewController:(UIViewController *)controller
{
  [UIView animateWithDuration:0.5 animations:^{
    self.window.rootViewController.view.alpha = 0.0f;
  } completion:^(BOOL finished) {
    controller.view.alpha = 0.0f;
    self.window.rootViewController = controller;
    [UIView animateWithDuration:0.5 animations:^{
      self.window.rootViewController.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
  }];
}

@end
