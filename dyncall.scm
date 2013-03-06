#>
#include <dyncall.h>
#include <dynload.h>
<#

(module dyncall
*
(import scheme chicken foreign)
(define-foreign-type dl-lib    (c-pointer "DLLib"))
(define-foreign-type dl-syms   (c-pointer "DLSyms"))
(define-foreign-type dc-vm     (c-pointer "DCCallVM"))
(define-foreign-type dc-struct (c-pointer "DCstruct"))

(define make-vm
  (foreign-lambda dc-vm dcNewCallVM size_t))
(define free-vm
  (foreign-lambda void dcFree dc-vm))

(define vm-reset
  (foreign-lambda void dcReset dc-vm))
(define vm-mode
  (foreign-lambda void dcMode dc-vm int))

(define vm-bool-arg
  (foreign-lambda void dcArgBool     dc-vm bool))
(define vm-char-arg
  (foreign-lambda void dcArgChar     dc-vm char))
(define vm-short-arg
  (foreign-lambda void dcArgShort    dc-vm short))
(define vm-int-arg
  (foreign-lambda void dcArgInt      dc-vm int))
(define vm-long-arg
  (foreign-lambda void dcArgLong     dc-vm long))
(define vm-long-long-arg
  (foreign-lambda void dcArgLongLong dc-vm integer64))
(define vm-float-arg
  (foreign-lambda void dcArgFloat    dc-vm float))
(define vm-double-arg
  (foreign-lambda void dcArgDouble   dc-vm double))
(define vm-pointer-arg
  (foreign-lambda void dcArgPointer  dc-vm c-pointer))
(define vm-cstring-arg
  (foreign-lambda void dcArgPointer  dc-vm c-string))
(define vm-struct-arg
  (foreign-lambda void dcArgStruct   dc-vm dc-struct c-pointer))

(define vm-call-void
  (foreign-lambda void      dcCallVoid     dc-vm c-pointer))
(define vm-call-bool
  (foreign-lambda bool      dcCallBool     dc-vm c-pointer))
(define vm-call-char
  (foreign-lambda char      dcCallChar     dc-vm c-pointer))
(define vm-call-short
  (foreign-lambda short     dcCallShort    dc-vm c-pointer))
(define vm-call-int
  (foreign-lambda int       dcCallInt      dc-vm c-pointer))
(define vm-call-long
  (foreign-lambda long      dcCallLong     dc-vm c-pointer))
(define vm-call-long-long
  (foreign-lambda integer64 dcCallLongLong dc-vm c-pointer))
(define vm-call-float
  (foreign-lambda float     dcCallFloat    dc-vm c-pointer))
(define vm-call-double
  (foreign-lambda double    dcCallDouble   dc-vm c-pointer))
(define vm-call-pointer
  (foreign-lambda c-pointer dcCallPointer  dc-vm c-pointer))
(define vm-call-cstring
  (foreign-lambda c-string  dcCallPointer  dc-vm c-pointer))
(define vm-call-struct
  (foreign-lambda void      dcCallStruct   dc-vm c-pointer dc-struct c-pointer))

(define struct-define
  (foreign-lambda dc-struct dcDefineStruct    c-string))
(define make-struct
  (foreign-lambda dc-struct dcNewStruct       size_t int))
(define free-struct
  (foreign-lambda void      dcFreeStruct      dc-struct))
(define struct-field
  (foreign-lambda void      dcStructField     dc-struct int int size_t))
(define struct-sub
  (foreign-lambda void      dcSubStruct       dc-struct size_t int size_t))
(define struct-close
  (foreign-lambda void      dcCloseStruct     dc-struct))
(define struct-size
  (foreign-lambda size_t    dcStructSize      dc-struct))


(define dl-load-library
  (foreign-lambda dl-lib    dlLoadLibrary c-string))
(define dl-free-library
  (foreign-lambda void      dlFreeLibrary dl-lib))
(define dl-find-symbol
  (foreign-lambda c-pointer dlFindSymbol  dl-lib c-string))

(define dl-syms-init 
  (foreign-lambda dl-syms  dlSymsInit          c-string))
(define dl-syms-cleanup
  (foreign-lambda void     dlSymsCleanup       dl-syms))
(define dl-syms-count
  (foreign-lambda int      dlSymsCount         dl-syms))
(define dl-syms-name
  (foreign-lambda c-string dlSymsName          dl-syms int))
(define dl-syms-name-from-value
  (foreign-lambda c-string dlSymsNameFromValue dl-syms c-pointer))


(define-syntax dyncall*
  (er-macro-transformer
   (lambda (x r c)
     (let ((vm (cadr x))
	   (return-type (caddr x))
	   (func-ptr (cadddr x))
	   (arg-map (cddddr x))

	   (%begin (r 'begin))
	   (%vm-reset (r 'vm-reset))
	   (%vm-bool-arg (r 'vm-bool-arg))
	   (%vm-char-arg (r 'vm-char-arg))
	   (%vm-short-arg (r 'vm-short-arg))
	   (%vm-int-arg (r 'vm-int-arg))
	   (%vm-long-arg (r 'vm-long-argx))
	   (%vm-longlong-arg (r 'vm-longlong-arg))
	   (%vm-float-arg (r 'vm-float-arg))
	   (%vm-double-arg (r 'vm-double-arg))
	   (%vm-pointer-arg (r 'vm-pointer-arg))
	   (%vm-cstring-arg (r 'vm-cstring-arg))
	   (%vm-call-void (r 'vm-call-void))
	   (%vm-call-bool (r 'vm-call-bool))
	   (%vm-call-char (r 'vm-call-char))
	   (%vm-call-short (r 'vm-call-short))
	   (%vm-call-int (r 'vm-call-int))
	   (%vm-call-long (r 'vm-call-long))
	   (%vm-call-longlong (r 'vm-call-longlong))
	   (%vm-call-float (r 'vm-call-float))
	   (%vm-call-double (r 'vm-call-double))
	   (%vm-call-pointer (r 'vm-call-pointer))
	   (%vm-call-cstring (r 'vm-call-cstring)))

       `(,%begin
	  (,%vm-reset vm)
	  ,@(map (lambda (arg)
	     (let ((type  (car  arg))
		   (value (cadr arg)))
	       (case type
		 ((bool)      `(,%vm-bool-arg     vm ,value))
		 ((char)      `(,%vm-char-arg     vm ,value))
		 ((short)     `(,%vm-short-arg    vm ,value))
		 ((int)       `(,%vm-int-arg      vm ,value))
		 ((long)      `(,%vm-long-arg     vm ,value))
		 ((longlong)  `(,%vm-longlong-arg vm ,value))
		 ((float)     `(,%vm-float-arg    vm ,value))
		 ((double)    `(,%vm-double-arg   vm ,value))
		 ((c-pointer) `(,%vm-pointer-arg  vm ,value))
		 ((c-string)  `(,%vm-cstring-arg) vm ,value))))
	   arg-map)
	  ,(case return-type
	     ((void)      `(,%vm-call-void     ,vm ,func-ptr))
	     ((bool)      `(,%vm-call-bool     ,vm ,func-ptr))
	     ((char)      `(,%vm-call-char     ,vm ,func-ptr))
	     ((short)     `(,%vm-call-short    ,vm ,func-ptr))
	     ((int)       `(,%vm-call-int      ,vm ,func-ptr))
	     ((long)      `(,%vm-call-long     ,vm ,func-ptr))
	     ((longlong)  `(,%vm-call-longlong ,vm ,func-ptr))
	     ((float)     `(,%vm-call-float    ,vm ,func-ptr))
	     ((double)    `(,%vm-call-double   ,vm ,func-ptr))
	     ((c-pointer) `(,%vm-call-pointer  ,vm ,func-ptr))
	     ((c-string)  `(,%vm-call-cstring  ,vm ,func-ptr))))))))

(define-syntax dyncall
  (er-macro-transformer
   (lambda (x r c)
     (let ((return-type (cadr x))
	   (func-ptr (caddr x))
	   (arg-map (cdddr x))

	   (%let (r 'let))
	   (%length (r 'length))
	   (%make-vm (r 'make-vm))
	   (%free-vm (r 'free-vm))
	   (%vm-mode (r 'vm-mode))
	   (%dyncall* (r 'dyncall*)))

       `(,%let ((vm (,%make-vm ,(length arg-map))))
	  (,%vm-mode vm 0)
	    (,%let ((return-value (,%dyncall* vm ,return-type ,func-ptr ,@arg-map)))
	      (,%free-vm vm)
	      return-value))))))

(define-syntax dyncall-lambda
  (er-macro-transformer
   (lambda (x r c)
     (let ((return-type (cadr x))
	   (func-ptr (caddr x))
	   (arg-types (cdddr x))
	   
	   (%let  (r 'let))
	   (%lambda (r 'lambda))
	   (%make-vm (r 'make-vm))
	   (%vm-mode (r 'vm-mode))
	   (%dyncall* (r 'dyncall*)))

       (let* ((arg-names (map (lambda (i) (string->symbol (format "a~A" i))) (iota (length arg-types))))
	      (arg-map (map (lambda (type name) `(,type ,name)) arg-types arg-names)))
	 `(,%let ((vm (,%make-vm ,(length arg-types)))
		  (ptr ,func-ptr))
	    (,%vm-mode vm 0)
	    (,%lambda ,arg-names
	      (,%dyncall* vm ,return-type ptr ,@arg-map))))))))

(define-syntax dyncall-lambda*
  (er-macro-transformer
   (lambda (x r c)
     (let ((return-type (cadr x))
	   (sym-spec (caddr x))
	   (arg-types (cdddr x)))

       (let ((lib-ptr (car sym-spec))
	     (sym-name (symbol->string (cadr sym-spec)))

	     (%let (r 'let))
	     (%dl-find-symbol (r 'dl-find-symbol))
	     (%dyncall-lambda (r 'dyncall-lambda)))

	 (if (list? sym-spec)
	     `(,%let ((func-ptr (,%dl-find-symbol ,lib-ptr ,sym-name)))
		(,%dyncall-lambda ,return-type func-ptr ,@arg-types))
	     (error 'dyncall-lambda "cached lib lookup not implemented" '(exn dyncall)))))))))
