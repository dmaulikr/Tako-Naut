//
//  TNAppDelegate.h
//  PsyNaut
//
//  Created by mugx on 22/02/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ScreenType) {
  STMenu,
  STTutorial,
  STNewGame,
  STResumeGame,
  STSettings,
  STHighScores,
  STAchievements,
  STCredits
};

@interface TNAppDelegate : UIResponder <UIApplicationDelegate>
+ (TNAppDelegate *)sharedInstance;
- (void)selectScreen:(ScreenType)screenType;
@property(nonatomic,strong) UIWindow *window;
@end
