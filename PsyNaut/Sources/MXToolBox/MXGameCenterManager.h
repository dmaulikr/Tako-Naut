//
//  MXGameCenterManager.h
//  MXToolBox
//
//  Created by mugx on 06/06/14.
//  Copyright (c) 2014 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface MXGameCenterManager : NSObject <GKGameCenterControllerDelegate>
+ (instancetype)sharedInstance;
- (void)authenticateLocalPlayer:(void (^)(BOOL isEnabled))completion;
- (void)saveScore:(int64_t)score;
- (void)showLeaderboard;
- (void)saveAchievement:(NSString *)achievementID;
- (void)resetAchievements;
- (void)showAchievements;
@property(nonatomic,assign) BOOL gameCenterEnabled;
@end