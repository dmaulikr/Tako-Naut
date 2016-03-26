//
//  MXToolBox.h
//  MXToolBox
//
//  Created by mugx on 13/01/16.
//  Copyright © 2016 mugx. All rights reserved.
//  

#ifndef MXToolBox_h
#define MXToolBox_h

#import "MXUtils.h"
#import "MXLocalizationManager.h"
#import "MXGameCenterManager.h"
#import "MXLabel.h"
#import "MXButton.h"
#import "MXImageView.h"
#import "UIImage+MX.h"
#import "UIColor+MX.h"

#define LOCALIZE(k) [[MXLocalizationManager sharedInstance] localize:k]
#define FONT_FAMILY @"Joystix"
#define MXLog(s) if (DEBUG) NSLog(s)

#endif /* MXToolBox_h */
