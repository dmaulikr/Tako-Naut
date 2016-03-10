#import "MXMazeGenerator.h"

#define NORTH 'N'
#define EAST 'E'
#define WEST 'W'
#define SOUTH 'S'

@interface MXMazeGenerator()
{
@private
  NSUInteger _width;
  NSUInteger _height;
  bool **_maze;
  NSMutableArray *_moves;
  CGPoint _start;
}
@end

@implementation MXMazeGenerator

- (id)initWithRow:(NSUInteger)row col:(NSUInteger)col startingPosition:(CGPoint)position
{
  if ((self = [super init]))
  {
    _width	= col * 2 + 1;
    _height	= row * 2 + 1;
    _start = position;
    _maze = (bool **)calloc(_height, sizeof(bool *));
    
    for (int r = 0; r < _height;++r)
    {
      _maze[r] = (bool *)calloc(_width, sizeof(bool));
      
      for (int c = 0; c < _width; c++)
      {
        _maze[r][c] = true;
      }
    }
    _maze[(int)_start.x][(int)_start.y] = false;
  }
  return self;
}

- (void)calculateMaze:(void (^)(bool **))completion
{
  int back;
  int move;
  NSString *possibleDirections;
  CGPoint pos = _start;
  
  _moves = [NSMutableArray new];
  
  [_moves addObject:[NSNumber numberWithInt:pos.y + (pos.x * _width)]];
  
  while ([_moves count])
  {
    possibleDirections = @"";
    
    if ((pos.x + 2 < _height ) && (_maze[(int)pos.x + 2][(int)pos.y] == true) && (pos.x + 2 != false) && (pos.x + 2 != _height - 1) )
    {
      possibleDirections = [possibleDirections stringByAppendingFormat:@"%c", SOUTH];
    }
    
    if ((pos.x - 2 >= 0 ) && (_maze[(int)pos.x - 2][(int)pos.y] == true) && (pos.x - 2 != false) && (pos.x - 2 != _height - 1) )
    {
      possibleDirections = [possibleDirections stringByAppendingFormat:@"%c", NORTH];
    }
    
    if ((pos.y - 2 >= 0 ) && (_maze[(int)pos.x][(int)pos.y - 2] == true) && (pos.y - 2 != false) && (pos.y - 2 != _width - 1) )
    {
      possibleDirections = [possibleDirections stringByAppendingFormat:@"%c", WEST];
    }
    
    if ((pos.y + 2 < _width ) && (_maze[(int)pos.x][(int)pos.y + 2] == true) && (pos.y + 2 != false) && (pos.y + 2 != _width - 1) )
    {
      possibleDirections = [possibleDirections stringByAppendingFormat:@"%c", EAST];
    }
    
    if (possibleDirections.length > 0)
    {
      move = [self randIntMin:0 andMax:((int)possibleDirections.length - 1)];
      
      const char *array = [possibleDirections UTF8String];
      
      switch (array[move])
      {
        case NORTH:
          _maze[(int)pos.x - 2][(int)pos.y] = false;
          _maze[(int)pos.x - 1][(int)pos.y] = false;
          pos.x -=2;
          break;
          
        case SOUTH:
          _maze[(int)pos.x + 2][(int)pos.y] = false;
          _maze[(int)pos.x + 1][(int)pos.y] = false;
          pos.x +=2;
          break;
          
        case WEST:
          _maze[(int)pos.x][(int)pos.y - 2] = false;
          _maze[(int)pos.x][(int)pos.y - 1] = false;
          pos.y -=2;
          break;
          
        case EAST:
          _maze[(int)pos.x][(int)pos.y + 2] = false;
          _maze[(int)pos.x][(int)pos.y + 1] = false;
          pos.y +=2;
          break;
      }
      
      [_moves addObject:[NSNumber numberWithInt:pos.y + (pos.x * _width)]];
    }
    else
    {
      back = [[_moves lastObject] intValue];
      [_moves removeLastObject];
      pos.x = (int)(back / _width);
      pos.y = back % _width;
    }
  }

  if (completion)
  {
    completion(_maze);
  }
}

- (void)logMatrix
{
  for (int x = 0; x < _height; x++)
  {
    for (int y = 0; y < _width; y++)
    {
      NSLog(@"[%d , %d] = %d", x, y, _maze[x][y]);
    }
  }
}

- (int)randIntMin:(int)min andMax:(int)max
{
  return ((arc4random() % (max - min +1)) + min);
}

@end