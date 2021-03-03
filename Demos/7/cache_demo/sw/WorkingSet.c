/*
  WorkingSet.c

  

*/

#include <stdio.h>
#include "system.h"
#include "alt_types.h"
#include <time.h>
#include <sys/alt_timestamp.h>
#include <sys/alt_cache.h>

#define N 8192

alt_u32 ticks;
alt_u32 time_1;
alt_u32 time_2;
alt_u32 timer_overhead;

float microseconds(int ticks)
{
  return (float) 1000000 * (float) ticks / (float) alt_timestamp_freq();
}

void initArray(int x[], int n)
{
  int i = 0;
  for(i = 1; i < n; i++)
    x[i] = i;
}


void start_measurement()
{

      /* Flush caches */
      alt_dcache_flush_all();
      alt_icache_flush_all();   
      /* Measure */
      alt_timestamp_start();
      time_1 = alt_timestamp();
}

void stop_measurement()
{
      time_2 = alt_timestamp();
      ticks = time_2 - time_1;
}

int main ()
{
  int w[8192];
      
  printf("Working Set\n\n");
  printf("Information about the system:\n");
  printf("\n");
  printf("Processor Type: %s\n", NIOS2_CPU_IMPLEMENTATION);
  printf("Size Instruction Cache: %d\n", NIOS2_ICACHE_SIZE);
  printf("Line Size Instruction Cache: %d\n", NIOS2_ICACHE_LINE_SIZE);
  printf("Size Data Cache: %d\n", NIOS2_DCACHE_SIZE);
  printf("Line Size Data Cache: %d\n\n", NIOS2_DCACHE_LINE_SIZE);

  /* Check if timer available */
  if (alt_timestamp_start() < 0)
    printf("No timestamp device available!");
  else
    {

      /* Print Information about the system */

      /* Print frequency and period */
      printf("Timestamp frequency: %3.1f MHz\n", (float)alt_timestamp_freq()/1000000.0);
      printf("Timestamp period:    %f ms\n\n", 1000.0/(float)alt_timestamp_freq());  


      /* Calculate Timer Overhead */
      // Average of 10 measurements */
      int i;
      timer_overhead = 0;
      for (i = 0; i < 10; i++) {      
        start_measurement();
        stop_measurement();
        timer_overhead = timer_overhead + time_2 - time_1;
      }
      timer_overhead = timer_overhead / 10;
        
      printf("Timer overhead in ticks: %d\n", (int) timer_overhead);
      printf("Timer overhead in ms:    %f\n", 
	     1000.0 * (float)timer_overhead/(float)alt_timestamp_freq());

       
    //Function 3.1
    printf("Function 3.1\n");
    int jmax = 12;
    int j;
    int y;
    while (jmax > 0) {
       initArray(w, 8192);
       printf("Enter a new value for jmax (Finish with 0): ");
       scanf("%d", &jmax);
       start_measurement();  
       y = 0;
       for(i = 0; i < 100; i++)
         for(j = 0; j < jmax; j++)
            y += w[j];
       stop_measurement();
       printf("y = %d - (%5.2f us)", y, microseconds(ticks - timer_overhead));
       printf("(%d ticks)\n", (int) (ticks - timer_overhead));   
    }      
    printf("Done!\n");
  }    
  return 0;
}
