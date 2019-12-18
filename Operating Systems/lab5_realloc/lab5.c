#include <stdio.h> //printf
#include <stdlib.h> // malloc


void updateArraySize(int **x, int n, int nNew);


int main()
{
  int **str, i,j ,count;
  str =(int**)malloc(3*sizeof(int*));
  for(i=0; i<3; i++)
   {
      str[i] = (int*)malloc(sizeof(int)*4);
   }
  count = 0;
  for (i = 0; i <  3; i++)
     for (j = 0; j < 4; j++)
      *(*(str+i)+j) = ++count;

printf("Before\n");
for (i=0; i<3; i++){
  for(j=0; j<4; j++ ){
    printf("%d ", *(*(str+i)+j));

  }
  printf("\n");
}

updateArraySize(str, 12 ,20);

printf("After\n");
for (i=0; i<3; i++){
  for(j=0; j<6; j++ ){
    printf("%d ", *(*(str+i)+j));

  }
  printf("\n");
}



return 0;
}

void updateArraySize(int **x, int n, int nNew){
/*
  n Original size of Array
  nNew Size of array after update
  x pointer to the array pointer
*/
if(nNew>n)
  {
    *x = (int *)realloc(*x, nNew*sizeof(int));
    wmemset(&x[0][4], *(*x+3), 2*sizeof(int));
    wmemset(*(x+1)+4, 918, 2*sizeof(int));

  }else if(nNew<n){

  }
  else{
    return;
  }
  return;
}
