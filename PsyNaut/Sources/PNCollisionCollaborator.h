//
//  PNCollisionCollaborator.h
//  Psynaut
//
//  Created by mugx on 18/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PNGameSession;

@interface PNCollisionCollaborator : NSObject
- (instancetype)init:(PNGameSession *)gameSession;
- (bool)checkCollision:(CGRect)frame;
- (void)update:(CGFloat)deltaTime;
@end
