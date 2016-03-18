#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MazeTyleType) {
  MTWall,
  MTPath,
  MTStart,
  MTEnd
};

@interface PNMazeGenerator : NSObject
- (instancetype)initWithRow:(NSUInteger)row col:(NSUInteger)col startingPosition:(CGPoint)position;
- (void)calculateMaze:(void (^)(MazeTyleType **))completion;
@end
