#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MazeTyleType) {
  MTWall,
  MTPath,
  MTStart,
  MTEnd
};

@interface PNMazeGenerator : NSObject
- (instancetype)initWithRow:(NSUInteger)row col:(NSUInteger)col startingPosition:(CGPoint)position;
@property(nonatomic,assign) MazeTyleType **maze;
@end
