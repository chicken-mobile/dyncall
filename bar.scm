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




(define-record callback signature pointer gc-root)

(define (proc->pointer foo)
  (callback-pointer (procedure-data foo)))
(define-foreign-type chicken-callback c-pointer proc->pointer)


(define dispatch-later
  (foreign-lambda void dispatch_later chicken-callback))


(let ((testo (make-gc-root)))

  (let* ((sig '(void (float int int)))       
	 (proc (lambda (f i ii) (print "baaaam!") 42))       
	 (gcr (make-gc-root)))
    (gc-root-set! gcr proc)

    (let ((func_ptr (dcb-new-callback (signature (void (float int int))) chicken-callback gcr)))
      (set! proc (extend-procedure proc (make-callback sig func_ptr gcr)))

      (proc 0.1 2 3)
      (dispatch-later proc)

      (thread-join! callback-thread))))



;; (pp (gc-root-ref (global-lookup "make-gc-root")))
;; (define-record callback signature pointer gc-root)


;; (let* ((sig (void (float int int)))       
;;        (proc (lambda (f i ii) (print "baaaam!")))       
;;        (gcr (make-gc-root)))
;;   (gc-root-set! gcr proc)

;;   (let ((func_ptr (dcb-new-callback (signature sig) chicken-callback gcr)))
;;     (extend-procedure! proc (make-callback sig func_ptr gcr))))


;; (let ((callback (dcb-new-callback (signature (void (float int int))) chicken-callback testo)))
;;   (let loop ()
;;     (thread-sleep! 1)
;;     (dispatch-later callback)
;;     (flush-output)
;;     (thread-sleep! 1)))

;; (let ((callin (callback-lambda void ((float f) (int i) (int ii))
;; 	        (print (format "~A + ~A + ~A = ~A" f i ii (+ f i ii))))))
;;   (callin 0.1 2 3)
;;   (dispatch-later callin))




