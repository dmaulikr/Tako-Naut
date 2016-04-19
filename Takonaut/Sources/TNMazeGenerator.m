#import "TNMazeGenerator.h"

typedef NS_ENUM(NSUInteger, DirectionType) {
  DTNorth,
  DTSouth,
  DTEast,
  DTWest
};

@interface TNMazeGenerator()
@property(nonatomic,assign) NSUInteger width;
@property(nonatomic,assign) NSUInteger height;
@property(nonatomic,assign) CGPoint start;
@end

@implementation TNMazeGenerator

- (MazeTyleType **)calculateMaze:(NSUInteger)row col:(NSUInteger)col startingPosition:(CGPoint)position
{
  _width	= col;
  _height	= row;
  _start = position;
  
  //--- init maze ---//
  MazeTyleType **maze = (MazeTyleType **)calloc(_height, sizeof(MazeTyleType *));
  for (int r = 0; r < _height;++r)
  {
   maze[r] = (MazeTyleType *)calloc(_width, sizeof(MazeTyleType));
  }

  int posX = (int)self.start.x;
  int posY = (int)self.start.y;

  //--- taking start tile ---//
  maze[posX][posY] = MTStart;

  NSMutableArray<NSDictionary *> *visitedTiles = [@[] mutableCopy];
  NSMutableArray *currentPath = [@[@{@"x" : @(posX), @"y" : @(posY)}] mutableCopy];
  while ([currentPath count])
  {
    //--- digging in some diretions ---//
    NSMutableArray<NSNumber *> *possibleDirections = [NSMutableArray<NSNumber *> array];
    if ((posX - 2 >= 0) && (maze[posX - 2][posY] == MTWall))
    {
      [possibleDirections addObject:@(DTNorth)];
    }
    
    if ((posX + 2 < self.height) && (maze[posX + 2][posY] == MTWall))
    {
      [possibleDirections addObject:@(DTSouth)];
    }
    
    if ((posY + 2 < self.width) && (maze[posX][posY + 2] == MTWall))
    {
      [possibleDirections addObject:@(DTEast)];
    }
    
    if ((posY - 2 >= 0) && (maze[posX][posY - 2] == MTWall))
    {
      [possibleDirections addObject:@(DTWest)];
    }
    
    if (possibleDirections.count > 0) // forward
    {
      DirectionType direction = [possibleDirections[arc4random() % possibleDirections.count] shortValue];
      switch (direction)
      {
        case DTNorth: {
          maze[posX - 2][posY] = MTPath;
          maze[posX - 1][posY] = MTPath;
          posX -= 2;
          break;
        }
        case DTSouth: {
          maze[posX + 2][posY] = MTPath;
          maze[posX + 1][posY] = MTPath;
          posX += 2;
          break;
        }
        case DTEast: {
          maze[posX][posY + 2] = MTPath;
          maze[posX][posY + 1] = MTPath;
          posY += 2;
          break;
        }
        case DTWest: {
          maze[posX][posY - 2] = MTPath;
          maze[posX][posY - 1] = MTPath;
          posY -= 2;
          break;
        }
      }
      [currentPath addObject:@{@"x" : @(posX), @"y" : @(posY)}];
      [visitedTiles addObject:@{@"x" : @(posX), @"y" : @(posY), @"steps" : @(currentPath.count * 2)}];
    }
    else //backtracking
    {
      NSDictionary *back = [currentPath lastObject];
      posX = [back[@"x"] intValue];
      posY = [back[@"y"] intValue];
      [currentPath removeLastObject];
    }
  }
  
  //--- taking end tile ---//
  NSDictionary *end;
  for (NSDictionary *tile in visitedTiles)
  {
    if ([tile[@"steps"] intValue] >= [end[@"steps"] intValue])
    {
      end = tile;
    }
  }
  maze[[end[@"x"] intValue]][[end[@"y"] intValue]] = MTEnd;
  return maze;
}

@end