//
//  UIView+Explode.m
//  Psynaut
//
//  Created by mugx on 07/04/16.
//  Copyright © 2016 mugx. All rights reserved.

#import "UIImageView+MX.h"

@implementation UIImageView (MX)

- (void)explode:(void (^)())completion
{  
  //--- preparing tile stuff ---//
  CGImageRef originalImage = self.image.CGImage;
  [self setImage:nil];
  
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
      if (x + 1 == fullColumns && remainderWidth > 0)
      {
        tileSize.width = remainderWidth;
      }
      
      if (y + 1 == fullRows && remainderHeight > 0)
      {
        tileSize.height = remainderHeight;
      }
      
      UIImageView *subTile = [[UIImageView alloc] init];
      subTile.layer.frame = CGRectMake(x * imageSize.width, y * imageSize.height, tileSize.width, tileSize.height);
      CGImageRef tileImage = CGImageCreateWithImageInRect(originalImage, subTile.layer.frame);
      subTile.layer.contents = (__bridge id)(tileImage);
      CGImageRelease(tileImage);
      [self addSubview:subTile];
    }
  }
  
  //--- starting to animate the sub tiles ---//
  for (UIImageView *subTile in self.subviews)
  {
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
      int randx = (arc4random() % 2 == 0 ? -1 : 1) * (arc4random() % 100);
      int randy = (arc4random() % 2 == 0 ? -1 : 1) * (arc4random() % 100);
      subTile.frame = CGRectMake(subTile.frame.origin.x + randx, subTile.frame.origin.y + randy, subTile.frame.size.width, subTile.frame.size.height);;
      subTile.alpha = 0;
    } completion:^(BOOL finished) {
      [subTile removeFromSuperview];
      
      if (completion && self.subviews.count == 0)
      {
        completion();
      }
    }];
  }
}

@end