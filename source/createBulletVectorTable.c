//
//  createBulletVectorTable.c
//  px
//
//  Created by Richard Löwenstein on 28.01.20.
//  Copyright © 2020 spieleschreiber. All rights reserved.
//

/*
 * Calculates a gradient table for pairs of dx/dy in a given range.
 * Format: 8-bit 1.7 unsigned fixed point values between 0.0 and 1.0
 *             dx=0            dx=1            ... dx=range-1
 * dy=0:       <gradx>,<grady> <gradx>,<grady>     <gradx>,<grady>
 * dy=1:       <gradx>,<grady> <gradx>,<grady>     <gradx>,<grady>
 *  ...
 * dy=range-1: <gradx>,<grady> <gradx>,<grady>     <gradx>,<grady>
 */


#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>


static void writebyte(FILE *f,uint8_t b)
{
  if (fwrite(&b,1,1,f) != 1) {
    fprintf(stderr,"Write error!\n");
    fclose(f);
    exit(1);
  }
}


#if 0
static void writebe16(FILE *f,uint16_t v)
{
  writebyte(f,v>>8);
  writebyte(f,v&0xff);
}
#endif


int main(int argc,char *argv[])
{
  FILE *f;
  int entries,i;

  if (argc != 3) {
    printf("Usage: %s <entries in one dimension> <file name>\n",argv[0]);
    return 1;
  }

  /* check if number of entries is a power of 2, below 512 */
  entries = atoi(argv[1]);
  //entries = 32;
  for (i=0; i<8; i++) {
    if (entries & (1<<i))
      break;
  }
  if (entries & ~(1<<i)) {
    fprintf(stderr,"%d is not a power of 2, or greater than 256!\n",entries);
    return 1;
  }

  if ((f = fopen(argv[2],"wb"))) {
 
    double dx,dy,len;
    int row,col;

    /* calculate and write the table */
    for (row=0; row<entries; row++) {
      for (col=0; col<entries; col++) {
        dx = (double)64-col;
        dy = (double)64-row;
        //dy = (double)32;
        if ((len = sqrt(dx*dx+dy*dy))) {
          dx = (160.0*dx/len);	// insert /2 in front of asterisk for half speed of bullets 
          dy = (236.0*dy/len);	// here too. /3 for 1/3 speed of bullets 
			//printf("len %u",dy/len);
        }
        else
          dx = dy = 0.0;

        /* write two 8-bit 1.7 fixed-point values for the gradient */
        //dy = (double)127;
        
        writebyte(f,(uint8_t)dx);
        writebyte(f,(uint8_t)dy);
        //writebyte(f,(uint8_t)dx);
        //writebyte(f,(uint8_t)dy);
      }
    }
    fclose(f);
  }
  else {
    fprintf(stderr,"Cannot open \"%s\" for writing!\n",argv[2]);
    return 1;
  }

  return 0;
}
