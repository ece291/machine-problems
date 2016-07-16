  
//        Battletank Simulator : Part II
//        ------------------------------
//        ECE291: MP5
//        Prof. John W. Lockwood
//        Unversity of Illinois, Dept. of Electrical & Computer Engineering
//        ; Assistant Guest Authors: Mike Carter, Johanna Canniff
//        Fall 1997
//        Revision 1.0



// ------------------- New ScaleTank Procedure for MP5 ----------------------

// (You need to write the Assembly code for these routines in MP5.ASM)

extern void far ScaleTank(int  XPos, int YPos,  /* X,Y Position on Scren  */ \
                          int  ScaleF,          /* Scale Factor: 100=100% */ \
                          char Rotation,        /* Rotational View (0..4) */ \
                          char PlayerNum );     /* PlayerNum (0..4)       */

extern void far HallDemo(int delay);  /* Hallway Demo */

extern void far MyDemo  (int delay);  /* Demo of your own invention */                      

// -------------- Existing MP4/MP5 Procedures defined in MP5.ASM ------------

extern void far TestRoutine();
extern void far DrawPoly(int x1, int y1, int y3, \
                         int x2, int y2, int y4, \
                         unsigned char color);
extern void far LoadBackgroundPCX(char far *Fname);
extern void far LoadForegroundPCX(char far *Fname);
extern void far DelayTick(int clocks);
extern void far DrawBufferToScreen();
extern void far AnimateBackgroundToBuffer(int Horshift);
extern void far InstKey();
extern void far DeInstallKey();
extern void far ModeText();
extern void far ModeGraph();

// Procedures defined in LIBMP5

extern void far SetStart(); // From libmp5
extern void far mp5xit();

// External Variables

extern int  far ExitFlag;  //  Variables defined in mp5.asm, Set in MyKeyInt
extern int  far Xoffset;   
extern int  far Yoffset;   //  Note: _Underscore added to var names in ASM
extern int  far Zoom;      //  Note: _Zoom is new: responds to '+' & '-' keys

// -------------------- Global variables in C routine ----------------------

int CloudPos = 0;

void TankScreen (int x, int y, int scale, \
                 unsigned char  rotation, unsigned char tanknum) {
  AnimateBackgroundToBuffer( CloudPos = (CloudPos+1) % 320 ); // Move clouds
  ScaleTank(x,y,scale,rotation,tanknum); // Draw our tank in ScreenBuffer
  DrawBufferToScreen(); // Write to screen
}


main(int argc, char* argv[]) { // Program Usage :  'MAIN testcase delay'

    // Test Cases: 'MAIN 1 d ' : Illini tank in meadow (benchmark with d=0)
    //             'MAIN 2 d ' : 4 Tank vs. 4 Tank battlefield
    //   d=delay   'MAIN 3   ' : Interactive (ESC=exit, +/- Zoom, Arrows=Move)
    //  (1/18sec)  'MAIN 4 d ' : Hall Demo (your code)
    //   0=fast    'MAIN 5 d ' : Your Demo (your code)
    //             'MAIN 6   ' : TestRoutine 

  int i=0;
  int CloudPos=0;      // Local variables in Main
  int  x,  y,  scale;
  int x0, y0, scale0;
  int choice;
  int delay;

  SetStart(); // Start Clock Timer  (LIBMP5 call)

  ModeGraph(); // Switch to 320 x 200 graphics

  LoadBackgroundPCX( "horizon.pcx" );  // Load Graphics Data
  LoadForegroundPCX( "tankview.pcx" );

  if (argc == 3)
    delay = argv[2][0] - '0';   // Set user-specified delay (3rd argument)
  else                          
    delay = 0;


  if (argc >  1) switch (argv[1][0]) { // Read command line arguments


    case '1': // Single Tank Demo (high speed)

        x =  -40;      // Initially: Illini Tank on Left of screen (not visible)
        y =  100;      // Vertically Center 
        scale = 100;   // Scaled at 100%

        for ( ; x<120; x++) { // Enter screen from the left
          TankScreen ( x, y, scale, 3 , 1); DelayTick(delay); }

        for ( ; scale<750 ; scale+=5 ) { // Turn toward camera and advance
          TankScreen ( x, y, scale, 0 , 1); DelayTick(delay); }

        for ( ; x<220 ; x++) { // Move more to the right
          TankScreen ( x, y, scale, 3 , 1); DelayTick(delay); }

        for ( ; scale>10; scale-=5) { // Turn away and move back
          TankScreen ( x, y, scale, 2 , 1); DelayTick(delay); }

        for ( ; scale<100; scale+=1) { // Turn away and move back
          TankScreen ( x, y, scale, 0 , 1); DelayTick(delay); }

        for ( ; x<320 ; x++) { // Move more to the right
          TankScreen ( x, y, scale, 3 , 1); DelayTick(delay); }

        break;

    case '2': // Two Tank Demo

          for ( x=1 ; x<110 ; x++, x0--) {
            AnimateBackgroundToBuffer( CloudPos = (CloudPos+1) % 320 );
            for (y=0; y<4; y++ ) {
              ScaleTank(    x, y*40+10 , 31*y+27 , 3, 0); // Left Tanks 
              ScaleTank(320-x, y*40+10 , 35*y+17 , 1, 1); // Right Tanks 
            }

            DrawBufferToScreen(); // Write to screen
            DelayTick(delay);
          }

        AnimateBackgroundToBuffer( CloudPos = (CloudPos+1) % 320 );
            for (y=0; y<4; y++ ) {
              ScaleTank(    x, y*40+10 , 31*y+27 , 4, 0); // Left Tanks 
              ScaleTank(320-x, y*40+10 , 35*y+17 , 1, 1); // Right Tanks 
            }

        DrawBufferToScreen(); // Write to screen
        DelayTick(30*delay);

        break;

    case '3': // Move around the screen using [LEFT], [RIGHT], [UP], [DOWN]

        x = 160;      
        y = 100;      // Start at Middle of screen
        scale = 100;

        InstKey();
        while (ExitFlag!=1) {

          x += Xoffset;
          y += Yoffset;
          scale += Zoom;

          TankScreen ( x, y, scale, 0 , 1); // Illini tank at zero rotation

        }
        DeInstallKey();

        break;

    case '4': // Hallway Demo 

        HallDemo( delay ); // Call ASM Routine
        break;

    case '5':

        MyDemo( delay ); // Your Demo (You may write this in ASM or C)
        break;

    case '6':

        TestRoutine(); // Useful For debugging (Use as you wish)
        break;

    default: ; 
  }

  ModeText();
  mp5xit();
 
}


