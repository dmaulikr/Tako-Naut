//
//  UIView+Explode.m
//  Psynaut
//
//  Created by mugx on 07/04/16.
//  Copyright © 2016 mugx. All rights reserved.

#import "UIImageView+Explode.h"

@implementation UIImageView (Explode)

- (void)explode:(void (^)())completion
{  
  //--- preparing tile stuff ---//
  CGImageRef originalImage = self.image.CGImage;
  [self setImage:nil];
  self.userInteractionEnabled = NO;
  
  //--- preparing sub tiles ---//
  float size = self.frame.size.width / 3.0;
  CGSize imageSize = CGSizeMake(size, size);
  CGFloat cols = self.frame.size.width / imageSize.width;
  CGFloat rows = self.frame.size.height /imageSize.height;
  
  int fullColumns = floorf(cols);
  int fullRows = floorf(rows);
  
  CGFloat remainderWidth = self.frame.size.width  - (fullColumns * imageSize.width);
  CGFloat remainderHeight = self.frame.size.height - (fullRows * imageSize.height);
  
  if (cols > fullColumns) fullColumns++;
  if (rows > fullRows) fullRows++;
  
  for (int y = 0; y < fullRows; ++y)
  {
    for (int x = 0; x < fullColumns; ++x)
    {
      CGSize tileSize = imageSize;
      if (x + 1 == fullColumns && remainderWidth > 0) // Last column
      {
        tileSize.width = remainderWidth;
      }
      
      if (y + 1 == fullRows && remainderHeight > 0) // Last row
      {
        tileSize.height = remainderHeight;
      }
      
      UIImageView *img = [[UIImageView alloc] init];
      img.layer.frame = CGRectMake(x * imageSize.width, y * imageSize.height, tileSize.width, tileSize.height);
      CGImageRef tileImage = CGImageCreateWithImageInRect(originalImage, img.layer.frame);
      img.layer.contents = (__bridge id)(tileImage);
      CGImageRelease(tileImage);
      [self addSubview:img];
    }
  }
  
  //--- starting to animate the sub tiles ---//
  for (UIImageView *subtile in self.subviews)
  {
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
      int randx = (arc4random() % 2 == 0 ? -1 : 1) * (arc4random() % 100);
      int randy = (arc4random() % 2 == 0 ? -1 : 1) * (arc4random() % 100);
      subtile.frame = CGRectMake(subtile.frame.origin.x + randx, subtile.frame.origin.y + randy, subtile.frame.size.width, subtile.frame.size.height);;
      subtile.alpha = 0;
    } completion:^(BOOL finished) {
      [subtile removeFromSuperview];
      
      if (completion && self.subviews.count == 0)
      {
        completion();
      }
    }];
  }
}

@end