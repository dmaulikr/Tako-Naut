//
//  PNTile+AI.h
//  Psynaut
//
//  Created by mugx on 15/04/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNTile.h"

@interface PNTile (AI)
CGFloat distance(CGRect rect1, CGRect rect2);
- (char)getBestDirection:(NSArray *)directions targetFrame:(CGRect)targetFrame;
- (bool)collidesTarget:(CGRect)target path:(NSArray *)path;
- (NSArray *)search:(CGRect)target;
@end
