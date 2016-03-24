//
//  PNEnemyCollaborator.h
//  Psynaut
//
//  Created by mugx on 23/03/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PNGameSession;

@interface PNEnemyCollaborator : NSObject
- (instancetype)init:(PNGameSession *)gameSession;
- (void)update:(CGFloat)deltaTime;
@property(readonly) NSMutableArray *enemies;
@end
