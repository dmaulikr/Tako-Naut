//
//  PNTile+AI.h
//  Psynaut
//
//  Created by mugx on 15/04/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import "PNTile.h"

@interface PNTile (AI)
- (bool)collidesTarget:(CGRect)target cells:(NSArray *)cells;
- (NSArray *)search:(CGRect)target;
@end
