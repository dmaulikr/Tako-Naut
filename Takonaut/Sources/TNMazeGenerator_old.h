#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MazeTyleType) {
  MTWall,
  MTPath,
  MTStart,
  MTEnd
};

@interface TNMazeGenerator : NSObject
- (MazeTyleType **)calculateMaze:(NSUInteger)row col:(NSUInteger)col startingPosition:(CGPoint)position;
@end
