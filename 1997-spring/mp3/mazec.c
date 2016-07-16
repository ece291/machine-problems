#include <stdlib.h>
#include <stdio.h>

#define MAZEROWS 23
#define MAZECOLS 80

#define WALL   0x0
#define ENDPOS 0x1
#define HALL   0x2
#define DECPOS 0x3

#define NORTH 0
#define EAST  1
#define SOUTH 2
#define WEST  3

extern void  far FXIT();
extern int   far ShowMaze();
extern int   far MazeManual();

extern unsigned char far MAZE;
extern int           far POS;

ReadMaze(char* fname) {
  FILE* fp;
  int x, y, ch;
  int position=0;

  fp = fopen(fname,"r"); // Open Maze File

  for (y=0; y<MAZEROWS; y++) { 
    for (x=0; ch!=EOF && x<MAZECOLS; x++) {

      ch = getc(fp);

      switch (ch) {
        case '#': *(&MAZE+position) = WALL; // Wall
                  break;
        case ' ': *(&MAZE+position) = HALL; // Hallway
                  break;
        case 'S': *(&MAZE+position) = HALL; // Starting Position
                  POS = position; 
                  break;    
        case 'E': *(&MAZE+position) = ENDPOS;
                  break;
        default:  *(&MAZE+position) = HALL; // Any other character (?)

      }

      position++;

    }
    while ((ch=getc(fp))!=10 && ch!=EOF);
    // Ignore any junk characters after 80th col
  }

  fclose(fp);

}


ProcessMaze() {
  int x, y, wallctr, position;

  for (y=1; y<(MAZEROWS-1); y++)
    for (x=1; x<(MAZECOLS-1); x++) {
      
      position=x+MAZECOLS*y;
      if (*(&MAZE+position) == HALL) {

        wallctr=0;

        if (*(&MAZE+position+1)==WALL) 
          wallctr++;
        if (*(&MAZE+position-1)==WALL) 
          wallctr++;
        if (*(&MAZE+position+MAZECOLS)==WALL) 
          wallctr++;
        if (*(&MAZE+position-MAZECOLS)==WALL) 
          wallctr++;
        
        if (wallctr<2) *(&MAZE+position) = DECPOS;
      }
    }
}

main() {

  ReadMaze("MAZE.DTA");
  ProcessMaze();
  ShowMaze();
  MazeManual();

  FXIT();
}
