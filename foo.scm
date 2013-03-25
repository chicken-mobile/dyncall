#>
#include <dynload.h>
#include <dyncall.h>
#include <dyncall_callback.h>
#include <dyncall_args.h>

#include <unistd.h>

int callback_fd = -1;

C_word call_args;
extern char chicken_callback(DCCallback* pcb, DCArgs* args, DCValue* result, void* clojure){
  if (callback_fd >= 0) {
    static float x;
    static   int y;
    static   int z;
    
    x = dcbArgFloat(args);
    y =   dcbArgInt(args);
    z =   dcbArgInt(args);

    printf("float: %f\nint: %d\nint: %d\n", x, y, z);

    C_word *ptr = C_alloc(C_SIZEOF_LIST(2));
    C_word arglst;
  
    arglst = C_list(&ptr, 2, C_fix(y), C_fix(z));
    call_args = clojure;
    
    result->p = clojure;		;
    write(callback_fd, "-", 1);
    return('i');
  }
  return(0);
}

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>


void* delayed_dispatch(void* foo){
  typedef void (*fptr)(float, int, int);
  fptr gptr = (fptr) foo;  
    
  sleep(5);
  gptr(0.1, 2, 3);
  printf("whooooot?\n");
}

void dispatch_later(void* func_ptr){
  pthread_t delay_thread;
  pthread_create(&delay_thread, NULL, delayed_dispatch, func_ptr);
}

<#

(define dispatch-later
  (foreign-lambda void dispatch_later (c-pointer void)))

(define (callin)
  (print "here is clalin :)"))







(use dyncall srfi-1 srfi-18 posix extras alist-lib expand-full)

(define-foreign-type dc-args     (c-pointer "struct DCArgs"))
(define chicken-callback
  (foreign-value "&chicken_callback" (function char (c-pointer c-pointer c-pointer c-pointer))))

(define hatchi '(1 2 3 4))

(define-external call_args scheme-object)  
(define testonto
  (foreign-lambda* scheme-object ()
		   "C_return(call_args);"))



(let* ((cb-handler chicken-callback)
       (sig (signature (scheme-object (float int int))))
       (callback (dcb-new-callback* sig chicken-callback (lambda (a b c) (print a b c)))))

  (pp cb-handler)
  (pp sig)
  (pp callback)

  (dispatch-later callback)

;;  (pp call-args)
  
  (define-external callback_fd int -1)
  (define-external callback_id int -1)

  (define miau
    (make-mutex))
  (define ready 
    (make-condition-variable 'testo))

  (mutex-lock! miau)
  (thread-start!
   (make-thread
    (lambda ()    
      (let-values (((in out) (create-pipe)))
	(set! callback_fd out)
	(let ((in* (open-input-file* in)))
	  (condition-variable-signal! ready)
	  (print "entering the loop")
	  (let loop ()
	    (print "starting to sit on the pipe")
	    (thread-wait-for-i/o! in)
	    (print "zzZzZzz !!! whoa whats on?")

	    (read-char in*)
	    (print "aha ok got that...")

	    (print "dont speak to me till im finished!!")
	    (mutex-lock! miau)
	    (print "done!")
	    (condition-variable-signal! ready)

	    (loop)))))))
  (mutex-unlock! miau ready)

(thread-sleep! 10)

#;
  (let loop ()
    (print "lets wake him up!")
    (pp (dyncall scheme-object callback (float 0.123) (int 1) (int 2)))
    (mutex-unlock! miau ready)
    
    (pp "foo?")
    (pp (testonto))

    (print "ok let him sleep\n")
    (thread-sleep! 5)
    (loop)))





(exit -1)


;; 
;; (pp (signature (void (float int int))))

;; (let* ((jvm-so   (dl-load-library "/usr/lib/jvm/java-7-openjdk/jre/lib/amd64/server/libjvm.so"))
;;        (jvm-syms (dl-syms-init "/usr/lib/jvm/java-7-openjdk/jre/lib/amd64/server/libjvm.so"))
;;        (syms-count   (dl-syms-count jvm-syms)))

;;   (pp jvm-so)
;;   (pp syms-count)

;;   (pp (map (lambda (i)
;; 	     (dl-syms-name jvm-syms i))
;; 	   (iota syms-count)))

;;   (let ((jvm-create (dl-find-symbol jvm-so "JNI_CreateJavaVM")))
;;     (pp (dl-syms-name-from-value jvm-syms jvm-create))
    
;;     ))

;; c function call_our_func
;; set the callback
;; call call_our_func
;; callback gets excuted
;; return value ǵets back to call_our_func
;; return value rearives at tha caller

;; (define-external (our_func (int int1) (int int2)) bool
;;   (print "miau alter!"))





;; (define-external callback_fd int -1)
;; (define-external callback_id int -1)

;; (define (make-waiter-thread)
;;   (let-values (((in out) (create-pipe)))
;;     (set! callback_fd out)
;;     (let ((p (open-input-file* in)))
;;       (is-ready)
;;       (let loop ()
;; 	(flush-output)
;; 	(thread-wait-for-i/o! in)
;; 	(let ((v (read-char p)))
;; 	  (unless (eof-object? v)
;; 		  (exit -1)
;; 		  (loop))
;; 	  (close-input-port p))))))

;; (define our-func
;;   (foreign-value "&chicken_callback" (function bool (int))))

;; (define foo
;;   (thread-start! (make-thread make-waiter-thread)))

;; (define (is-ready)
;;   (pp (dyncall bool our-func (int 1)))
;;   (pp (dyncall bool our-func (int 1)))
;;   (pp (dyncall bool our-func (int 1)))
;;   (pp (dyncall bool our-func (int 1))))


;; (define-external callback_fd int -1)
;; (define-external callback_id int -1)


;; (define our-func
;;   (foreign-value "&chicken_callback" (function bool (int))))

;; (define miau
;;   (make-mutex))
;; (define ready 
;;   (make-condition-variable 'testo))

;; (mutex-lock! miau)
;; (thread-start!
;;  (make-thread
;;   (lambda ()    
;;     (let-values (((in out) (create-pipe)))
;;       (set! callback_fd out)
;;       (let ((in* (open-input-file* in)))
;; 	(condition-variable-signal! ready)
;; 	(print "entering the loop")
;; 	(let loop ()
;; 	  (print "starting to sit on the pipe")
;; 	  (thread-wait-for-i/o! in)
;; 	  (print "zzZzZzz !!! whoa whats on?")

;; 	  (read-char in*)
;; 	  (print "aha ok got that...")

;; 	  (print "dont speak to me till im finished!!")
;; 	  (mutex-lock! miau)
;; 	  (thread-sleep! 1)
;; 	  (print "done!")
;; 	  (condition-variable-signal! ready)

;; 	  (loop)))))))
;; (mutex-unlock! miau ready)

#;
(let loop ()
  (print "lets wake him up!")

  (dyncall bool our-func (int 1))
  (mutex-unlock! miau ready)

  (print "ok let him sleep\n")
  (thread-sleep! 1))
(loop)
  




