#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MazeTyleType) {
  MTWall,
  MTPath,
  MTStart,
  MTEnd
};

@interface TNMazeGenerator_old : NSObject
- (MazeTyleType **)calculateMaze:(CGPoint)start height:(NSUInteger)height width:(NSUInteger)width;
@end
