#import "MXMazeGenerator.h"

typedef NS_ENUM(NSUInteger, DirectionType) {
  DTNorth,
  DTSouth,
  DTEast,
  DTWest
};

@interface Tile : NSObject
@property(nonatomic,assign) int x;
@property(nonatomic,assign) int y;
@property(nonatomic,assign) int stepsFromOrigin;
@end

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
  
  int stepsCount = 0;
  NSMutableArray<Tile*> *frontierCells = [@[] mutableCopy];
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
      Tile *tile = [Tile new];
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
      
      //--- adding current frontier tile ---//
      stepsCount += 2;
      tile.x = posX;
      tile.y = posY;
      tile.stepsFromOrigin = stepsCount;
      [frontierCells addObject:tile];
    }
    else //backtracking
    {
      NSArray *back = [univistedCells lastObject];
      posX = [back[0] intValue];
      posY = [back[1] intValue];
      [univistedCells removeLastObject];
      stepsCount--;
    }
  }
  
  Tile *end = [Tile new];
  for (Tile *tile in frontierCells)
  {
    if (tile.stepsFromOrigin >= end.stepsFromOrigin)
    {
      end = tile;
    }
  }
  self.maze[end.x][end.y] = MTEnd;
  
  if (completion)
  {
    completion(self.maze);
  }
}

@end

@implementation Tile
@end