//
//  TNMacros.h
//  Takonaut
//
//  Created by mugx on 17/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#ifndef TNMacros_h
#define TNMacros_h

#import "MXToolBox.h"

#define GAME_CENTER_ENABLED !DEBUG
//#define FONT_FAMILY @"C64 User"

#define WHITE_COLOR [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define GREEN_COLOR [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:1.0]
#define ELECTRIC_COLOR [UIColor colorWithRed:100.0/255.0 green:0.0/255.0 blue:100.0/255.0 alpha:1.0]
#define MAGENTA_COLOR [UIColor colorWithRed:255.0/255.0 green:0.0/255.0 blue:255.0/255.0 alpha:1.0]
#define CYAN_COLOR [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define BLACK_COLOR [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]
#define YELLOW_COLOR [UIColor colorWithRed:230.0/255.0 green:220.0/255.0 blue:0.0 alpha:1.0]
#define RED_COLOR [UIColor redColor]
#define BLUE_COLOR [UIColor blueColor]

#define TICK NSDate *startTime = [NSDate date]
#define TOCK(s) NSLog(s, -[startTime timeIntervalSinceNow])
#define RAND(a, b) ((((float) rand()) / (float) RAND_MAX) * (b - a)) + a

#define SOUND_ENABLED true
#define SOUND_DEFAULT_VOLUME 0.5

#endif /* TNMacros_h */
