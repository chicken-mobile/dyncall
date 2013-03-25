#>
#include "suppe.c"
<#
(use dyncall srfi-18 posix)

(define-external callback_pipe_fd_out int -1)
(define-external callback_pipe_fd_in  int -1)
(define-external callback_args dc-args)
(define-external callback c-pointer)


(define-foreign-type dc-args (c-pointer "struct DCArgs"))


(define dispatch-later
  (foreign-lambda void dispatch_later (c-pointer void)))
(define chicken-callback
  (foreign-value "&dyncall_chicken_callback" (function char (c-pointer c-pointer c-pointer c-pointer))))

(define callback-mutex
  (make-mutex))
(define chcken-ready
  (make-condition-variable 'chicken-ready))

(define callback-thread
  (make-thread
   (lambda ()
     (let-values (((in out) (create-pipe))
		  ((in1 out1) (create-pipe)))
       (set! callback_pipe_fd_out out)
       (set! callback_pipe_fd_in  in1)
       
       (let ((in* (open-input-file* in))
	     (out* (open-output-file* out1)))
	 
	 (let loop ()
	   (thread-wait-for-i/o! in)
	   (read-char in*)


	   (pp callback_args)
;;	   (pp (dcb-arg-float callback_args))
;;	   (pp (dcb-arg-int callback_args))
;;	   (pp (dcb-arg-int callback_args))
	   (pp (gc-root-ref callback))

	   (let ((wurst (apply (gc-root-ref callback)
			       `(,(dcb-arg-float callback_args)
				 ,(dcb-arg-int   callback_args)
				 ,(dcb-arg-int   callback_args)))))
	     (pp wurst))

	   (write-char #\- out*)
	   (flush-output   out*)

	   (loop)
	   ))))))

(thread-start! callback-thread)

(define make-gc-root
  (foreign-lambda (c-pointer void) CHICKEN_new_gc_root))
(define gc-root-ref
  (foreign-lambda scheme-object CHICKEN_gc_root_ref (c-pointer void)))
(define gc-root-set!
  (foreign-lambda void CHICKEN_gc_root_set (c-pointer void) scheme-object))

(define global-lookup
  (foreign-lambda c-pointer CHICKEN_global_lookup c-string))


(pp (gc-root-ref (global-lookup "make-gc-root")))

(let ((testo (make-gc-root)))
  (gc-root-set! testo 
		(lambda (f i ii)
		  (print "biste verrückt ?")
		  42))

  (let ((callback (dcb-new-callback (signature (void (float int int))) chicken-callback testo)))
    (thread-sleep! 1)

    (let loop ()
      (thread-sleep! 1)
      (dispatch-later callback)
      (flush-output)
      (loop))))


