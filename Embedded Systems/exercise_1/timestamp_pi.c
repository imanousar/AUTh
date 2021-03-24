// Libraries we need
#include <sys/time.h>
#include <time.h>
#include "stdlib.h"
#include "stdio.h"
#include "unistd.h"
#include "math.h"
#include <signal.h>

void make_timestamps_without(float total_time, float interval, int arr_size);
void make_timestamps(float total_time, float interval, int arr_size);
void writeData(long int timestamps[], int size);
void writeData_2(long int timestamps[], int size);
void create_graphs();
void alarmHandler(int sig);

int flag = 1;

int main(int argc , char *argv[])
{
    signal(SIGALRM,alarmHandler);

    float total_time =(float) atof(argv[1]); // getting duration of program
    float interval =(float) atof(argv[2]);  //  getting interval
    int arr_size = (int) (total_time / interval) ;
    printf("Total time is : %f\nInterval every %f sec\nTotal samples taken are: %d\n", total_time, interval, arr_size+1);
    if(atoi(argv[3])==1){
      make_timestamps(total_time,interval,arr_size);
      create_graphs();
    }
    if(atoi(argv[3])==2){
          make_timestamps_without(total_time,interval,arr_size);
        }
  return 0;
}


void make_timestamps(float total_time, float interval, int arr_size)
{
  // function to take timestamps
  struct timeval tv;
  volatile time_t curtime;
  long int timestamps[arr_size];
  int index = 0;
  int sleeping_time = (int) (interval * pow(10,6));
  printf("sleeping_time %d us\n", sleeping_time );
  alarm(total_time);
  while(flag)
  {
    gettimeofday(&tv, NULL);
    curtime=tv.tv_sec*pow(10,6) + tv.tv_usec;
    timestamps[index]=curtime;
    usleep(sleeping_time);
    printf("Timestamp of test %d is %ld\n", index+1,timestamps[index]);
    index++;
  }

  writeData(timestamps, arr_size);
}

void writeData(long int timestamps[],int size){
  // save timestamps
  FILE *fp = fopen("samples.txt", "w+");
  for(int n=0;n<=size;n++) {
    fprintf(fp,"%ld\n",timestamps[n]);
  }
  fclose(fp);

  // save time of packages
  FILE *f = fopen("packages_time.txt", "w+");
  for(int n=1;n<=size;n++) {
    fprintf(f,"%ld\n",timestamps[n]-timestamps[n-1]);
  }
  fclose(fp);

}

void create_graphs()
{
  int unused __attribute__((unused));
  // make plot of packages with plot.py
  unused = system("python plot.py");
}



void delay(int number_of_seconds)
{
    // Converting time into milli_seconds
    int milli_seconds = 1000 * number_of_seconds;

    // Stroing start time
    clock_t start_time = clock();

    // looping till required time is not acheived
    while (clock() < start_time + milli_seconds)
        ;
}

void make_timestamps_without(float total_time, float interval, int arr_size)
{

  float count = 0;
  long int timestamps[arr_size];
  clock_t start, end;
  int index = 0, delay_time = (int) (interval * 1000);
  printf("sleeping_time %d ms\n", delay_time );
  while(count<=total_time)
  {
    start = clock();
    delay(delay_time);
    end = clock();
    timestamps[index] = end - start;
    printf("Time of package %d is %ld ms\n", index+1, timestamps[index]);
    index++;
    count+=interval;
}
  writeData_2(timestamps, arr_size);
}

void writeData_2(long int timestamps[],int size){
  FILE *fp = fopen("packages_time.txt", "w+");
  for(int n=0;n<=size;n++) {
    fprintf(fp,"%ld\n",timestamps[n]);
  }
  fclose(fp);
}

void alarmHandler(int sig){
	flag = 0;
}
