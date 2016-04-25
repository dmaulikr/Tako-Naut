//
//  TNAppDelegate.m
//  PsyNaut
//
//  Created by mugx on 22/02/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "TNAppDelegate.h"
#import "TNMenuViewController.h"
#import "TNTutorialViewController.h"
#import "TNGameViewController.h"
#import "TNSettingsViewController.h"
#import "TNHighScoresViewController.h"
#import "TNCreditsViewController.h"
#import "MXToolBox.h"
#import "TNMacros.h"
#import <MXAudioManager/MXAudioManager.h>

@interface TNAppDelegate ()
@end

@implementation TNAppDelegate

int main(int argc, char * argv[]) { @autoreleasepool { return UIApplicationMain(argc, argv, nil, NSStringFromClass([TNAppDelegate class])); } }

+ (TNAppDelegate *)sharedInstance
{
  return (TNAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  //--- Load Splash View Controller first ---//
  self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
  UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"LaunchScreen"];
  self.window.rootViewController = viewController;
  [self.window makeKeyAndVisible];
  
  //-- prepare sounds ---//
  [self prepareSounds];
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
    self.window.rootViewController = [TNMenuViewController create];
  });
  
  return YES;
}

- (void)prepareSounds
{
  [MXAudioManager sharedInstance].soundEnabled = SOUND_ENABLED;
  [MXAudioManager sharedInstance].volume = SOUND_DEFAULT_VOLUME;
  id json = [MXUtils jsonFromFile:@"gameConfiguration.json"];
  [[MXAudioManager sharedInstance] load:json];
}

#pragma mark - Select Screen

- (void)selectScreen:(ScreenType)screenType
{
  switch (screenType) {
    case STMenu:
      [self transitionToViewController:[TNMenuViewController create]];
      break;
    case STTutorial:
      [self transitionToViewController:[TNTutorialViewController create]];
      break;
    case STNewGame:
      self.gameVc = [TNGameViewController create];
      [self transitionToViewController:self.gameVc];
      break;
    case STResumeGame:
      [self transitionToViewController:self.gameVc];
      break;
    case STHighScores:
      if ([[MXGameCenterManager sharedInstance] gameCenterEnabled])
      {
        [[MXGameCenterManager sharedInstance] showLeaderboard];
      }
      else
      {
        [self transitionToViewController:[TNHighScoresViewController create]];
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
      [self transitionToViewController:[TNSettingsViewController create]];
      break;
    case STCredits:
      [self transitionToViewController:[TNCreditsViewController create]];
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
