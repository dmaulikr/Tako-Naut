#import "TNMazeGenerator_old.h"

@implementation TNMazeGenerator_old

- (MazeTyleType **)calculateMaze:(CGPoint)start height:(NSUInteger)height width:(NSUInteger)width
{
  //--- init maze ---//
  MazeTyleType **maze = (MazeTyleType **)calloc(height, sizeof(MazeTyleType *));
  for (int r = 0; r < height;++r)
  {
   maze[r] = (MazeTyleType *)calloc(width, sizeof(MazeTyleType));
  }

  int posX = (int)start.x;
  int posY = (int)start.y;

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
      [possibleDirections addObject:@('n')];
    }
    
    if ((posX + 2 < height) && (maze[posX + 2][posY] == MTWall))
    {
      [possibleDirections addObject:@('s')];
    }
    
    if ((posY + 2 < width) && (maze[posX][posY + 2] == MTWall))
    {
      [possibleDirections addObject:@('w')];
    }
    
    if ((posY - 2 >= 0) && (maze[posX][posY - 2] == MTWall))
    {
      [possibleDirections addObject:@('w')];
    }
    
    if (possibleDirections.count > 0) // forward
    {
      char direction = [possibleDirections[arc4random() % possibleDirections.count] shortValue];
      switch (direction)
      {
        case 'n': {
          maze[posX - 2][posY] = MTPath;
          maze[posX - 1][posY] = MTPath;
          posX -= 2;
          break;
        }
        case 's': {
          maze[posX + 2][posY] = MTPath;
          maze[posX + 1][posY] = MTPath;
          posX += 2;
          break;
        }
        case 'e': {
          maze[posX][posY + 2] = MTPath;
          maze[posX][posY + 1] = MTPath;
          posY += 2;
          break;
        }
        case 'w': {
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