// **************************************************************
// MP0c: Demo C Program                                         
// Your Name: Current Date                                      
// **************************************************************

// Describe what this program does, in your own words.

// Declare external functions from external libraries
#include <stdlib.h>
#include <stdio.h>

// Define constants
// Values are substituted into your code at compile time.
#define BEL    0x07
#define ESCKEY 0x1b

// Procedure to read keyboard input
char inecho() {
  char c;

  c = getch();                  // Get a character
  printf("%c",c);               // Echo it to the screen
  return(c);                    // Return character
}

// Main program
void main() {
  char  c;                        // Declare a character variable
  printf("MP0: Type \"N\" or the \"ESC\" key");

  // Repeat the following loop
  while(1) {
    printf("\nMP0:");           // Print prompt message

    c  = inecho();              // Get a character from keyboard

    switch(c) {                 // Perform action based  on input

    case ESCKEY:
      printf("\nMP0: Exit to DOS\n");
      exit(0);

      case 'N':
      printf("\nYour Name");
      break;

      default:
      printf("%c",BEL);
      break;
    }
  }
}
