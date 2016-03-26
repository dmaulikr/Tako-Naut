//
//  PNEnemy.h
//  Psynaut
//
//  Created by mugx on 23/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNGameSession.h"

@interface PNEnemy : UIImageView
- (instancetype)initWithFrame:(CGRect)frame withGameSession:(PNGameSession *)gameSession;
- (void)update:(CGFloat)deltaTime;
@property(nonatomic,assign) float speed;
@end
