//
//  UIImage+MX.m
//  CyyC
//
//  Created by mugx on 26/11/15.
//  Copyright © 2015 mugx. All rights reserved.
//

#import "UIImage+MX.h"

@implementation UIImage (MX)

- (UIImage *)imageColored:(UIColor *)color
{
  UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
  [color setFill];
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextTranslateCTM(context, 0, self.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  CGContextSetBlendMode(context, kCGBlendModeNormal);
  CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
  CGContextClipToMask(context, rect, self.CGImage);
  CGContextFillRect(context, rect);
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

- (UIImage*)scale:(CGFloat)newHeight
{
  CGFloat newWidth = self.size.width * newHeight / self.size.height;
  CGSize newSize = CGSizeMake(newWidth, newHeight);
  UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
  [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

@end
