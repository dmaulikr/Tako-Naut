//
//  UIView+Explode.m
//  Psynaut
//
//  Created by mugx on 07/04/16.
//  Copyright © 2016 mugx. All rights reserved.

#import "UIImageView+Explode.h"
#import <objc/runtime.h>

#define RANDOM() (float)rand()/(float)RAND_MAX

@interface LPParticleLayer : CALayer
@property (nonatomic, strong) UIBezierPath *particlePath;
@end

@implementation LPParticleLayer
@end

@interface UIImageView()
@property (nonatomic, copy) void (^completion)();
@end

@implementation UIImageView (Explode)

- (void)setCompletion:(id)completion
{
  [self willChangeValueForKey:@"completion"];
  objc_setAssociatedObject(self, @selector(completion), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
  [self didChangeValueForKey:@"completion"];
}

- (id)completion
{
  return objc_getAssociatedObject(self,@selector(completion));
}

- (void)explode:(void (^)())completion
{
  self.completion = completion;
  
  //--- preparing tile stuff ---//
  CGImageRef originalImage = self.image.CGImage;
  [self setImage:nil];
  self.userInteractionEnabled = NO;
  
  //--- preparing sub tiles ---//
  float size = self.frame.size.width / 5.0;
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
      
      CGRect layerRect = (CGRect){{x*imageSize.width, y * imageSize.height}, tileSize};
      CGImageRef tileImage = CGImageCreateWithImageInRect(originalImage,layerRect);
      LPParticleLayer *layer = [LPParticleLayer layer];
      layer.frame = layerRect;
      layer.contents = (__bridge id)(tileImage);
      layer.borderWidth = 0.0f;
      layer.borderColor = [UIColor blackColor].CGColor;
      layer.particlePath = [self pathForLayer:layer parentRect:self.layer.frame];
      [self.layer addSublayer:layer];
      CGImageRelease(tileImage);
    }
  }
  
  //--- starting to animate the sub tiles ---//
  for (LPParticleLayer *layer in self.layer.sublayers)
  {
    // moveAnim path
    CAKeyframeAnimation *moveAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnim.path = layer.particlePath.CGPath;
    moveAnim.removedOnCompletion = YES;
    moveAnim.fillMode = kCAFillModeForwards;
    [moveAnim setTimingFunctions:@[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]]];
    
    // transformAnim
    NSTimeInterval speed = 2.35 * RANDOM();
    CAKeyframeAnimation *transformAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D startingScale = layer.transform;
    CATransform3D endingScale = CATransform3DConcat(CATransform3DMakeScale(RANDOM(), RANDOM(), RANDOM()), CATransform3DMakeRotation(M_PI*(1 + RANDOM()), RANDOM(), RANDOM(), RANDOM()));
    [transformAnim setValues:@[[NSValue valueWithCATransform3D:startingScale], [NSValue valueWithCATransform3D:endingScale]]];
    [transformAnim setKeyTimes:@[@(0.0), @(speed*.25)]];
    [transformAnim setTimingFunctions:@[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]]];
    transformAnim.fillMode = kCAFillModeForwards;
    transformAnim.removedOnCompletion = NO;
    
    // alpha
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:1.0f];
    opacityAnim.toValue = [NSNumber numberWithFloat:0.f];
    opacityAnim.removedOnCompletion = NO;
    opacityAnim.fillMode = kCAFillModeForwards;
    
    // anim group
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:moveAnim,transformAnim,opacityAnim, nil];
    animGroup.duration = speed;
    animGroup.fillMode = kCAFillModeForwards;
    animGroup.delegate = self;
    [animGroup setValue:layer forKey:@"animationLayer"];
    [layer addAnimation:animGroup forKey:nil];
    
    //take it off screen
    [layer setPosition:CGPointMake(0, -600)];
  }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
  LPParticleLayer *layer = [theAnimation valueForKey:@"animationLayer"];
  
  if (layer)
  {
    //make sure we dont have any more
    if ([[self.layer sublayers] count] == 1)
    {
      if (self.completion)
      {
        self.completion();
      }
      [self removeFromSuperview];
    }
    else
    {
      [layer removeFromSuperlayer];
    }
  }
}

- (UIBezierPath *)pathForLayer:(CALayer *)layer parentRect:(CGRect)rect
{
  UIBezierPath *particlePath = [UIBezierPath bezierPath];
  [particlePath moveToPoint:layer.position];
  
  float r = RANDOM() + 0.3f;
  float r2 = RANDOM() + 0.4f;
  float r3 = r * r2;
  
  int upOrDown = (r <= 0.5) ? 1 : -1;
  
  CGPoint curvePoint = CGPointZero;
  CGPoint endPoint = CGPointZero;
  
  float maxLeftRightShift = 1.0f * RANDOM();
  
  CGFloat layerYPosAndHeight = (self.superview.frame.size.height - ((layer.position.y + layer.frame.size.height))) * RANDOM();
  CGFloat layerXPosAndHeight = (self.superview.frame.size.width - ((layer.position.x + layer.frame.size.width))) * r3;
  
  float endY = self.superview.frame.size.height-self.frame.origin.y;
  
  if (layer.position.x <= rect.size.width * 0.5)
  {
    //going left
    endPoint = CGPointMake(-layerXPosAndHeight, endY);
    curvePoint = CGPointMake((((layer.position.x * 0.5) * r3) * upOrDown) * maxLeftRightShift, -layerYPosAndHeight);
  }
  else
  {
    endPoint = CGPointMake(layerXPosAndHeight, endY);
    curvePoint = CGPointMake((((layer.position.x * 0.5)*r3) * upOrDown+rect.size.width) * maxLeftRightShift, -layerYPosAndHeight);
  }
  
  [particlePath addQuadCurveToPoint:endPoint controlPoint:curvePoint];
  return particlePath;
}

@end