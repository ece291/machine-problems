#include <stdlib.h>
#include <stdio.h>
#include <strings.h>

/* Text converter: Unix-to-Dos (u2d)  -and-  Dos-to-Unix (d2u) */
/* John Lockwood */

main( int argc , char* argv[] ) {
  register int c;

  if (strcmp(argv[0],"d2u")==0) {
    while ((c=getchar())!=EOF) {
      if (c!=13)
        putchar(c);
    }
  }
  else {
    while ((c=getchar())!=EOF) {
      if (c==10) putchar(13);
      putchar(c);
    }
  }
}
