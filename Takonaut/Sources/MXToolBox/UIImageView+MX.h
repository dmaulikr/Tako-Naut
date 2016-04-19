//
//  UIView+Explode.m
//  Takonaut
//
//  Created by mugx on 07/04/16.
//  Copyright © 2016 mugx. All rights reserved.

#import <UIKit/UIKit.h>

@interface UIImageView (MX)
- (void)explode:(void (^)())completion;
- (void)blink:(void (^)())completion;
@end