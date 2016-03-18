//
//  UIImage+MX.h
//  CyyC
//
//  Created by mugx on 26/11/15.
//  Copyright © 2015 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MX)
- (UIImage *)imageColored:(UIColor *)color;
- (UIImage*)scale:(CGFloat)newHeight;
- (NSArray *)spritesWiteSize:(CGSize)size;
- (NSArray *)spritesWithSize:(CGSize)size inRange:(NSRange)range;
@end
