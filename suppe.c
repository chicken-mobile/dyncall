#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#include <dynload.h>
#include <dyncall.h>
#include <dyncall_callback.h>
#include <dyncall_args.h>

int callback_pipe_fd_out = -1;
int callback_pipe_fd_in  = -1;
DCArgs* callback_args;
DCValue* callback_result;
void* callback;

char dyncall_chicken_callback(DCCallback* pcb, DCArgs* args, DCValue* result, void* hmmm){
  callback_args = args;  
  callback = hmmm;


  char readbuffer[1];
  write(callback_pipe_fd_out, "-", 1);
  read(callback_pipe_fd_in, readbuffer, 1);

  return('v');
}

typedef void (*fptr)(float, int, int);

void* delayed_dispatch(void* foo){
  fptr gptr = (fptr) foo;  
  gptr(12345.678, 9, 10);
}

void dispatch_later(void* func_ptr){
  pthread_t delay_thread;
  pthread_create(&delay_thread, NULL, delayed_dispatch, func_ptr);
}
