//
//  PNAppDelegate.h
//  PsyNaut
//
//  Created by mugx on 22/02/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ScreenType) {
  STMenu,
  STNewGame,
  STResumeGame,
  STSettings,
  STHighScores,
  STAchievements,
  STCredits
};

@interface PNAppDelegate : UIResponder <UIApplicationDelegate>
+ (PNAppDelegate *)sharedInstance;
- (void)selectScreen:(ScreenType)screenType;
@property(nonatomic,strong) UIWindow *window;
@end
