//
//  PNAppDelegate.m
//  PsyNaut
//
//  Created by mugx on 22/02/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNAppDelegate.h"
#import "PNGameViewController.h"
#import "MXToolBox.h"
#import "PNMacros.h"
#import <MXAudioManager/MXAudioManager.h>

@interface PNAppDelegate ()

@end

@implementation PNAppDelegate

int main(int argc, char * argv[]) { @autoreleasepool { return UIApplicationMain(argc, argv, nil, NSStringFromClass([PNAppDelegate class])); } }

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window.rootViewController = [PNGameViewController create];
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

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
