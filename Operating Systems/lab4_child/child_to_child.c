#include <stdlib.h> // malloc
#include <unistd.h> // execvp,fork
#include <sys/wait.h>//wait
#include <sys/types.h>//
#include <stdio.h> //printf
#include <errno.h>

void child1(int *fd, char **command)
{
    close(fd[0]);
 		dup2(fd[1],1); //dup(fd[1])
 		close(fd[0]);
 		close(fd[1]);
 if (execvp(*command, command)<0)
 {
   fprintf(stderr,"ERROR\n");
   exit(1);
 }
}

void child2(int *fd, char **string1){

  		dup2(fd[0],0); //dup(fd[0])
  		close(fd[0]);
  		close(fd[1]);
   if (execvp(*string1, string1)<0)
   {
     fprintf(stderr,"ERROR\n");
     exit(1);
    return;
  }
}

int main()
{
  int fd[2];
  char **command,**string1;
  pipe(fd);
  string1 =(char**) malloc(3*sizeof(*string1));
  command =(char**) malloc(3*sizeof(*command));
  command[0] = "fortune";
  command[1] = NULL;
  command[2] = NULL;
  string1[0] = "cowsay";
  string1[1] = NULL;
  string1[2] = NULL;


pid_t pid2, pid1 = fork();

  if (pid1  < 0) {     /* fork a child process           */
    printf("*** ERROR: forking child process failed\n");
    exit(1);
  }
else if (pid1 == 0){
  child1(fd, command);
}
else{

  pid2 = fork();
  if(pid2 == 0){
    child2(fd,string1);
  }

}
  close(fd[0]);
  close(fd[1]);

  free(string1);
  free(command);
  return 0;


}
