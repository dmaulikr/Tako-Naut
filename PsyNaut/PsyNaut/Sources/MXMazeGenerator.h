#import <UIKit/UIKit.h>

typedef void (^block)(bool **);

@interface MXMazeGenerator : NSObject
{
@private
    NSUInteger _width;
    NSUInteger _height;
    bool **_maze;
    NSMutableArray *_moves;
    CGPoint _start;
    block _response;
}

- (id)initWithRow:(NSUInteger)row andCol:(NSUInteger)col withStartingPoint:(CGPoint)position;
- (void)arrayMaze:(block)arrayMaze;
@end
