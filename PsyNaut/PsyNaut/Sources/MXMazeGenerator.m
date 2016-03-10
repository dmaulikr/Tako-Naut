#import "MXMazeGenerator.h"

#define NORTH 'N'
#define EAST 'E'
#define WEST 'W'
#define SOUTH 'S'

#define kNorthFlag 1
#define kEastFlag 2
#define kSouthFlag 4
#define kWestFlag 8

@implementation MXMazeGenerator

+ (int)drawPathWithFlagsNorth:(bool)north south:(bool)south east:(bool)east west:(bool)west
{
  int retValue = 0;
  
  if (north)
  {
    retValue |= kNorthFlag;
  }
  
  if (east)
  {
    retValue |= kEastFlag;
  }
  
  if (south)
  {
    retValue |= kSouthFlag;
  }
  
  if (west)
  {
    retValue |= kWestFlag;
  }
  
  return retValue;
}

- (id)initWithRow:(NSUInteger)row andCol:(NSUInteger)col withStartingPoint:(CGPoint)position
{
  if ((self = [super init]))
  {
    _width	= col * 2 + 1;
    _height	= row * 2 + 1;
    _start = position;
    
    [self initMaze];
  }
  
  return self;
}

- (void)initMaze
{
  _maze = (bool **)calloc(_height, sizeof(bool *));
  
  for (int r = 0; r < _height; r++)
  {
    _maze[r] = (bool *)calloc(_width, sizeof(bool));
    
    for (int c = 0; c < _width; c++)
    {
      _maze[r][c] = true;
    }
  }
  
  _maze[(int)_start.x][(int)_start.y] = false;
}

- (void)createMaze
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
  
  _response(_maze);
}

- (void)arrayMaze:(block)arrayMaze
{
  _response = nil;
  _response = arrayMaze;
  
  [self createMaze];
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