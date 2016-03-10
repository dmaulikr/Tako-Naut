#import <UIKit/UIKit.h>

@interface MXMazeGenerator : NSObject
- (id)initWithRow:(NSUInteger)row col:(NSUInteger)col startingPosition:(CGPoint)position;
- (void)calculateMaze:(void (^)(bool **))completion;
@end
