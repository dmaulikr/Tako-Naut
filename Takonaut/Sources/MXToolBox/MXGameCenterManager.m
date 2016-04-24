//
//  MXGameCenterManager.m
//  MXToolBox
//
//  Created by mugx on 06/06/14.
//  Copyright (c) 2014 mugx. All rights reserved.
//

#import "MXGameCenterManager.h"

@interface MXGameCenterManager ()
@property(nonatomic,strong) NSString *leaderboardIdentifier;
@property(nonatomic,strong) NSMutableDictionary *achievementsDictionary;
@end

@implementation MXGameCenterManager

+ (instancetype)sharedInstance
{
  static MXGameCenterManager *gameSettings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    gameSettings = [[self alloc] init];
  });
  return gameSettings;
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterViewController
{
  [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)authenticateLocalPlayer:(void (^)(BOOL isEnabled))completion
{
  /*
   if (!GAME_CENTER_ENABLED)
   {
   return;
   }
   */
  
  [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController *viewController, NSError *error)
  {
    if (viewController != nil)
    {
      [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:viewController animated:YES completion:nil];
      if (completion) completion(self.gameCenterEnabled);
    }
    else
    {
      if ([GKLocalPlayer localPlayer].authenticated)
      {
        // loading leaderboard
        [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error)
         {
           if (error != nil)
           {
             NSLog(@"%@", [error localizedDescription]);
           }
           else
           {
             self.gameCenterEnabled = YES;
             self.leaderboardIdentifier = leaderboardIdentifier;
             if (completion) completion(self.gameCenterEnabled);
           }
         }];
        
        // loading achievements
        //[self loadAchievements];
      }
      else
      {
        self.gameCenterEnabled = NO;
        if (completion) completion(self.gameCenterEnabled);
      }
    }
  };
}

- (void)saveScore:(int64_t)score
{
  if (!self.gameCenterEnabled) return;
  
  GKScore *leaderboardSore = [[GKScore alloc] initWithLeaderboardIdentifier:self.leaderboardIdentifier];
  leaderboardSore.value = score;
  
  [GKScore reportScores:@[leaderboardSore] withCompletionHandler:^(NSError *error)
   {
     if (error != nil)
     {
       NSLog(@"%@", [error localizedDescription]);
     }
   }];
}

#pragma mark - Achievements

- (void)loadAchievements
{
  self.achievementsDictionary = [[NSMutableDictionary alloc] init];
  [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
    if (error != nil)
    {
      // Handle the error.
      NSLog(@"Error while loading achievements: %@", error.description);
    }
    else if (achievements != nil)
    {
      // Process the array of achievements.
      for (GKAchievement* achievement in achievements)
      {
        self.achievementsDictionary[achievement.identifier] = achievement;
      }
    }
  }];
}

- (void)saveAchievement:(NSString *)achievementID
{
  
  GKAchievement *achievement = [self.achievementsDictionary objectForKey:achievementID];
  if (achievement == nil)
  {
    achievement = [[GKAchievement alloc] initWithIdentifier:achievementID];
    self.achievementsDictionary[achievement.identifier] = achievement;
  }
  
  if (achievement && achievement.percentComplete != 100.0) {
    achievement.percentComplete = 100;
    achievement.showsCompletionBanner = YES;
    
    [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
      if (error != nil) {
        NSLog(@"Error while reporting achievement: %@", error.description);
      }
    }];
  }
}

- (void)resetAchievements
{
  // Clear all locally saved achievement objects.
  self.achievementsDictionary = [[NSMutableDictionary alloc] init];
  
  // Clear all progress saved on Game Center.
  [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
   {
     if (error != nil) {
       // handle the error.
       NSLog(@"Error while reseting achievements: %@", error.description);
       
     }
   }];
}

- (void)showLeaderboard
{
  GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
  gcViewController.gameCenterDelegate = self;
  gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
  gcViewController.leaderboardIdentifier = self.leaderboardIdentifier;
  gcViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  gcViewController.modalPresentationStyle = UIModalPresentationFormSheet;
  [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:gcViewController animated:YES completion:nil];
}

- (void)showAchievements
{
  GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
  gcViewController.gameCenterDelegate = self;
  gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
  [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:gcViewController animated:YES completion:nil];
}

@end
