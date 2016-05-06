//
//  TNTile+AI.h
//  Takonaut
//
//  Created by mugx on 15/04/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "TNTile.h"

@interface TNTile (AI)
CGFloat distance(CGRect rect1, CGRect rect2);
- (char)getBestDirection:(NSArray *)directions targetFrame:(CGRect)targetFrame;
- (bool)collidesTarget:(CGRect)target path:(NSArray *)path;
- (NSArray *)search:(CGRect)target;
@end
