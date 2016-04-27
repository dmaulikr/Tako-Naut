//
//  TNMazeGenerator.hpp
//  Takonaut
//
//  Created by mugx on 27/04/16.
//  Copyright © 2016 mugx. All rights reserved.
//

#ifndef TNMazeGenerator_hpp
#define TNMazeGenerator_hpp

#include <stdio.h>

typedef enum
{
  CTWall,
  CTPath,
  CTStart,
  CTEnd
} CellType;

class TNMazeGenerator
{
public:
  //- (MazeTyleType **)calculateMaze:(NSUInteger)row col:(NSUInteger)col startingPosition:(CGPoint)position;
  //CellType** calculateMaze(int row, int col, int startingPosition);
};
#endif /* TNMazeGenerator_hpp */
