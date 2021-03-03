/* 
   MatrixAddition.c

  

*/

#include <stdio.h>
#include "system.h"
#include "alt_types.h"
#include <time.h>
#include <sys/alt_timestamp.h>
#include <sys/alt_cache.h>

#define N 24

int matrix[N][N]; 

/* Initialize the matrix */

void InitMatrix (int matrix[N][N]);
int SumByColRow (int matrix[N][N], int size);
int SumByRowCol (int matrix[N][N], int size);

alt_u32 ticks;
alt_u32 time_1;
alt_u32 time_2;
alt_u32 timer_overhead;
  

float microseconds(int ticks)
{
  return (float) 1000000 * (float) ticks / (float) alt_timestamp_freq();
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
  int a, b;
  int size = N;
     
  InitMatrix(matrix);

    /* Print Information about the system */
  printf("Working Set\n\n");
  printf("Information about the system:\n");
  printf("\n");
  printf("Processor Type: %s\n", NIOS2_CPU_IMPLEMENTATION);
  printf("Size Instruction Cache: %d\n", NIOS2_ICACHE_SIZE);
  printf("Line Size Instruction Cache: %d\n", NIOS2_ICACHE_LINE_SIZE);
  printf("Size Data Cache: %d\n", NIOS2_DCACHE_SIZE);
  printf("Line Size Data Cache: %d\n\n", NIOS2_DCACHE_LINE_SIZE);
    
  if (alt_timestamp_start() < 0)
    printf("No timestamp device available!");
  else {

    /* Print frequency and period */
    printf("Timestamp frequency: %3.1f MHz\n", 
          (float)alt_timestamp_freq()/1000000.0);
    printf("Timestamp period:    %f ms\n\n", 
	   1000.0/(float)alt_timestamp_freq());  

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


      // Calculate Time for SumByColRow
      printf("SumByColRow: ");
      start_measurement();
      a = SumByColRow (matrix, size);
      stop_measurement(); 
      printf("Result: %d\n", a);
      printf("%5.2f us", microseconds(ticks - timer_overhead));
      printf("(%d ticks)\n", (int) (ticks - timer_overhead)); 
    
      // Calculate Time for SumByRowCol 
      printf("SumByRowCol: ");
      start_measurement();
      b = SumByRowCol (matrix, size);
      stop_measurement();    
      printf("Result: %d\n", b);
      printf("%5.2f us", microseconds(ticks - timer_overhead));
      printf("(%d ticks)\n", (int) (ticks - timer_overhead)); 

      printf("Done!\n");
  }
  return 0;
}

void InitMatrix (int matrix[N][N]){
  int i, j;

  for (i = 0; i < N; i++) {
    for (j = 0; j < N; j++) {
      matrix[i][j] = i+j;
    }
  }
}

int SumByColRow (int matrix[N][N], int size)
{
  int i, j, Sum = 0;

  for (j = 0; j < size; j ++) {
    for (i = 0; i < size; i ++) {
      Sum += matrix[i][j];
    }
  }
  return Sum;
}

int SumByRowCol (int matrix[N][N], int size)
{
  int i, j, Sum = 0;

  for (i = 0; i < size; i ++) {
    for (j = 0; j < size; j ++) {
      Sum += matrix[i][j];
    }
  }
  return Sum;
}
