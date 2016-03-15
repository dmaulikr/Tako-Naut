#import "MXMazeGenerator.h"

typedef NS_ENUM(NSUInteger, DirectionType) {
  DTNorth,
  DTSouth,
  DTEast,
  DTWest
};

@interface MXMazeGenerator()
@property(nonatomic,assign) NSUInteger width;
@property(nonatomic,assign) NSUInteger height;
@property(nonatomic,assign) CGPoint start;
@property(nonatomic,assign) MazeTyleType **maze;
@end

@implementation MXMazeGenerator

- (instancetype)initWithRow:(NSUInteger)row col:(NSUInteger)col startingPosition:(CGPoint)position
{
  if ((self = [super init]))
  {
    _width	= col;
    _height	= row;
    _start = position;
    
    //--- init maze ---//
    _maze = (MazeTyleType **)calloc(_height, sizeof(MazeTyleType *));
    for (int r = 0; r < _height;++r)
    {
      _maze[r] = (MazeTyleType *)calloc(_width, sizeof(MazeTyleType));
    }
  }
  return self;
}

- (void)dealloc
{
  free(_maze);
}

- (void)calculateMaze:(void (^)(MazeTyleType **))completion
{
  int posX = (int)self.start.x;
  int posY = (int)self.start.y;
  
  self.maze[posX][posY] = MTStart;
  
  NSMutableArray *univistedCells = [@[@[@(posX), @(posY)]] mutableCopy];
  while ([univistedCells count])
  {
    //--- try to mine in some diretions ---//
    NSMutableArray<NSNumber *> *possibleDirections = [NSMutableArray<NSNumber *> array];
    if ((posX - 2 >= 0) && (self.maze[posX - 2][posY] == MTWall))
    {
      [possibleDirections addObject:@(DTNorth)];
    }
    
    if ((posX + 2 < self.height) && (self.maze[posX + 2][posY] == MTWall))
    {
      [possibleDirections addObject:@(DTSouth)];
    }
    
    if ((posY + 2 < self.width) && (self.maze[posX][posY + 2] == MTWall))
    {
      [possibleDirections addObject:@(DTEast)];
    }
    
    if ((posY - 2 >= 0) && (self.maze[posX][posY - 2] == MTWall))
    {
      [possibleDirections addObject:@(DTWest)];
    }
    
    if (possibleDirections.count > 0)
    {
      DirectionType direction = [possibleDirections[arc4random() % possibleDirections.count] shortValue];
      switch (direction)
      {
        case DTNorth: {
          self.maze[posX - 2][posY] = MTPath;
          self.maze[posX - 1][posY] = MTPath;
          posX -= 2;
          break;
        }
        case DTSouth: {
          self.maze[posX + 2][posY] = MTPath;
          self.maze[posX + 1][posY] = MTPath;
          posX += 2;
          break;
        }
        case DTEast: {
          self.maze[posX][posY + 2] = MTPath;
          self.maze[posX][posY + 1] = MTPath;
          posY += 2;
          break;
        }
        case DTWest: {
          self.maze[posX][posY - 2] = MTPath;
          self.maze[posX][posY - 1] = MTPath;
          posY -= 2;
          break;
        }
      }
      
      [univistedCells addObject:@[@(posX), @(posY)]];
    }
    else //backtracking
    {
      NSArray *back = [univistedCells lastObject];
      posX = [back[0] intValue];
      posY = [back[1] intValue];
      [univistedCells removeLastObject];
    }
  }
  
  if (completion)
  {
    completion(self.maze);
  }
}

@end