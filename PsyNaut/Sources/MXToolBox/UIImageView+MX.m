//
//  UIView+Explode.m
//  Psynaut
//
//  Created by mugx on 07/04/16.
//  Copyright © 2016 mugx. All rights reserved.

#import "UIImageView+MX.h"
#import "UIImage+MX.h"

#define ANIM_DURATION 1.0
#define SUB_TILE_DIVIDER_SIZE 5.0

@implementation UIImageView (MX)

- (void)explode:(void (^)())completion
{
  //--- checking image integrity ---//
  if (self.image == nil)
  {
    if (self.animationImages.count > 0)
    {
      self.image = self.animationImages[0];
      self.animationImages = nil;
    }
    else
    {
      return;
    }
  }
  
  //--- preparing sub tiles ---//
  float currentW = self.frame.size.width / SUB_TILE_DIVIDER_SIZE;
  float currentH = self.frame.size.height / SUB_TILE_DIVIDER_SIZE;
  float originalW = self.image.size.width / SUB_TILE_DIVIDER_SIZE;
  float originalH = self.image.size.height / SUB_TILE_DIVIDER_SIZE;
  int cols = floorf(self.image.size.width / originalW);
  int rows = floorf(self.image.size.height / originalH);
  
  for (int y = 0; y < cols; ++y)
  {
    for (int x = 0; x < rows; ++x)
    {
      CGRect frame = CGRectMake(x * originalW, y * originalH, originalW, originalH);
      UIImageView *subTile = [[UIImageView alloc] initWithImage:[self.image crop:frame]];
      subTile.frame = CGRectMake(x * currentW, y * currentH, currentW, currentH);
      [self addSubview:subTile];
    }
  }
  [self setImage:nil];
  
  //--- starting to animate the sub tiles ---//
  for (UIImageView *subTile in self.subviews)
  {
    [UIView animateWithDuration:ANIM_DURATION delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
      int randx = (arc4random() % 2 == 0 ? -1 : 1) * (arc4random() % 50);
      int randy = (arc4random() % 2 == 0 ? -1 : 1) * (arc4random() % 50);
      subTile.frame = CGRectOffset(subTile.frame, subTile.frame.origin.x + randx, subTile.frame.origin.y + randy);
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