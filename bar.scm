(use expand-full dyncall)
(import-for-syntax chicken) 

(define-syntax callback-lambda
  (er-macro-transformer
   (lambda (x r c)
     (let ((arg-map (cadr x))
	   (return-type (caddr x))
	   (body (cdddr x)))

       (receive (arg-types arg-names) (unzip2 arg-map)
		(let ((sig `(,return-type ,arg-types)))
		  `(let* ((gcr   (make-gc-root))
			  (func-ptr (dcb-new-callback (signature ,sig) chicken-callback gcr))
			  (proc (extend-procedure ,(append `(lambda ,arg-names) body)
						  (make-callback func-ptr ',return-type ',arg-types gcr))))
		     (gc-root-set! gcr proc) proc)))))))





#;
(ppexpand* '(callback-lambda ((float f) (int i) (int ii)) void
	      (print (format "~A + ~A + ~A = ~A" f i ii (+ f i ii)))))

#>
#include "suppe.c"
<#
(use dyncall srfi-18 posix lolevel)

(define-foreign-type dc-args (c-pointer "struct DCArgs"))
(define-foreign-type dc-value (c-pointer "DCValue"))

(define-external callback_pipe_fd_out int -1)
(define-external callback_pipe_fd_in  int -1)
(define-external callback_args dc-args)
(define-external callback_return_value dc-value)
(define-external callback c-pointer)



(define dispatch-later
  (foreign-lambda void dispatch_later c-pointer))
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

	   (let ((wurst (apply (gc-root-ref callback)
			       `(,(dcb-arg-float callback_args)
				 ,(dcb-arg-int   callback_args)
				 ,(dcb-arg-int   callback_args)))))
	     (pp wurst))

	   (write-char #\- out*)
	   (flush-output   out*)
	   (flush-output)

	   (loop)))))))

(thread-start! callback-thread)

(define make-gc-root
  (foreign-lambda c-pointer CHICKEN_new_gc_root))
(define gc-root-ref
  (foreign-lambda scheme-object CHICKEN_gc_root_ref c-pointer))
(define gc-root-set!
  (foreign-lambda void CHICKEN_gc_root_set c-pointer scheme-object))

(define global-lookup
  (foreign-lambda c-pointer CHICKEN_global_lookup c-string))




(define-record callback pointer return-type arg-types  gc-root)

(define (proc->pointer foo)
  (callback-pointer (procedure-data foo)))
(define-foreign-type chicken-callback c-pointer proc->pointer)


(define dispatch-later
  (foreign-lambda void dispatch_later chicken-callback))



(let ((foodo (callback-lambda ((float f) (int i) (int ii)) void
	       (print (format "~A + ~A + ~A = ~A" f i ii (+ f i ii))))))

  (pp (foodo 555.2 2 3))
  (thread-sleep! 1)

  (dispatch-later foodo)
  (thread-join! callback-thread))




