#import "MXMazeGenerator.h"

#define NORTH 'N'
#define EAST 'E'
#define WEST 'W'
#define SOUTH 'S'

@interface MXMazeGenerator()
@property(nonatomic,assign) NSUInteger width;
@property(nonatomic,assign) NSUInteger height;
@property(nonatomic,assign) NSUInteger startX;
@property(nonatomic,assign) NSUInteger startY;
@property(nonatomic,assign) bool **maze;
@property(nonatomic,strong) NSMutableArray *moves;
@end

@implementation MXMazeGenerator

- (instancetype)initWithRow:(NSUInteger)row col:(NSUInteger)col startingPosition:(CGPoint)position
{
  if ((self = [super init]))
  {
    _width	= col * 2 + 1;
    _height	= row * 2 + 1;
    _startX = position.x;
    _startY = position.y;
    
    //--- init maze ---//
    _maze = (bool **)calloc(_height, sizeof(bool *));
    for (int r = 0; r < _height;++r)
    {
      _maze[r] = (bool *)calloc(_width, sizeof(bool));
      
      for (int c = 0; c < _width; c++)
      {
        _maze[r][c] = true;
      }
    }
    _maze[_startX][_startY] = false;
  }
  return self;
}

- (void)dealloc
{
  free(_maze);
}

- (void)calculateMaze:(void (^)(bool **))completion
{
  int posX = (int)self.startX;
  int posY = (int)self.startY;
  NSString *possibleDirections;
  int back;
  int move;
  
  self.moves = [NSMutableArray new];
  [self.moves addObject:[NSNumber numberWithLong:posY + (posX * self.width)]];
  
  while ([self.moves count])
  {
    possibleDirections = @"";
    
    if ((posX + 2 < self.height ) && (self.maze[posX + 2][posY] == true) && (posX + 2 != false) && (posX + 2 != self.height - 1) )
    {
      possibleDirections = [possibleDirections stringByAppendingFormat:@"%c", SOUTH];
    }
    
    if ((posX - 2 >= 0 ) && (self.maze[posX - 2][posY] == true) && (posX - 2 != false) && (posX - 2 != self.height - 1) )
    {
      possibleDirections = [possibleDirections stringByAppendingFormat:@"%c", NORTH];
    }
    
    if ((posY - 2 >= 0 ) && (self.maze[posX][posY - 2] == true) && (posY - 2 != false) && (posY - 2 != self.width - 1) )
    {
      possibleDirections = [possibleDirections stringByAppendingFormat:@"%c", WEST];
    }
    
    if ((posY + 2 < self.width ) && (self.maze[posX][posY + 2] == true) && (posY + 2 != false) && (posY + 2 != self.width - 1) )
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
          self.maze[posX - 2][posY] = false;
          self.maze[posX - 1][posY] = false;
          posX -=2;
          break;
          
        case SOUTH:
          self.maze[posX + 2][posY] = false;
          self.maze[posX + 1][posY] = false;
          posX +=2;
          break;
          
        case WEST:
          self.maze[posX][posY - 2] = false;
          self.maze[posX][posY - 1] = false;
          posY -=2;
          break;
          
        case EAST:
          self.maze[posX][posY + 2] = false;
          self.maze[posX][posY + 1] = false;
          posY +=2;
          break;
      }
      
      [self.moves addObject:[NSNumber numberWithLong:posY + (posX * _width)]];
    }
    else
    {
      back = [[self.moves lastObject] intValue];
      [self.moves removeLastObject];
      posX = (int)(back / self.width);
      posY = back % self.width;
    }
  }
  
  if (completion)
  {
    completion(self.maze);
  }
}

- (int)randIntMin:(int)min andMax:(int)max
{
  return ((arc4random() % (max - min +1)) + min);
}

@end