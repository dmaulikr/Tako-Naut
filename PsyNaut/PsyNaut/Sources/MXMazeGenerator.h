#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MazeTyleType) {
  MTPath,
  MTWall,
  MTStart,
  MTEnd
};

@interface MXMazeGenerator : NSObject
- (instancetype)initWithRow:(NSUInteger)row col:(NSUInteger)col startingPosition:(CGPoint)position;
- (void)calculateMaze:(void (^)(MazeTyleType **))completion;
@end
