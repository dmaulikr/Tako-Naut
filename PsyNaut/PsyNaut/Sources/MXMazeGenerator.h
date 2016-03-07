#import <UIKit/UIKit.h>

typedef void (^block)(bool **);

@interface MXMazeGenerator : NSObject
{
@private
    uint _width;
    uint _height;
    bool **_maze;
    NSMutableArray *_moves;
    CGPoint _start;
    block _response;
}

- (id)initWithRow:(int)row andCol:(int)col withStartingPoint:(CGPoint)position;
- (void)arrayMaze:(block)arrayMaze;
@end
