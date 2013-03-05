#>
#include <dyncall.h>
#include <dynload.h>
<#

(module dyncall
*
(import scheme chicken foreign)
(define-foreign-type dynload-lib    (c-pointer "DLLib"))
(define-foreign-type dynload-syms   (c-pointer "DLSyms"))
(define-foreign-type dyncall-vm     (c-pointer "DCCallVM"))
(define-foreign-type dyncall-struct (c-pointer "DCstruct"))

(define-foreign-type dyncall-void      void)
(define-foreign-type dyncall-bool      bool)
(define-foreign-type dyncall-char      char)
(define-foreign-type dyncall-uchar     unsigned-char)
(define-foreign-type dyncall-short     short)
(define-foreign-type dyncall-ushort    unsigned-short)
(define-foreign-type dyncall-int       int)
(define-foreign-type dyncall-uint      unsigned-int)
(define-foreign-type dyncall-long      long)
(define-foreign-type dyncall-ulong     unsigned-long)
(define-foreign-type dyncall-longlong  long) ;; foo
(define-foreign-type dyncall-ulonglong unsigned-long) ;; bar
(define-foreign-type dyncall-float     float)
(define-foreign-type dyncall-double    double)
(define-foreign-type dyncall-pointer   c-pointer)
(define-foreign-type dyncall-cstring   c-string)
(define-foreign-type dyncall-size      size_t)

(define-foreign-variable dyncall-true  unsigned-int "DC_TRUE")
(define-foreign-variable dyncall-false unsigned-int "DC_FALSE")

(define-foreign-variable callconv/default            unsigned-int "DC_CALL_C_DEFAULT")
(define-foreign-variable callconv/ellipsis           unsigned-int "DC_CALL_C_ELLIPSIS")
(define-foreign-variable callconv/ellipsis-var-args  unsigned-int "DC_CALL_C_ELLIPSIS_VARARGS")
(define-foreign-variable callconv/x86-win32-cdecl    unsigned-int "DC_CALL_C_X86_CDECL")
(define-foreign-variable callconv/x86-win32-std      unsigned-int "DC_CALL_C_X86_WIN32_STD")
(define-foreign-variable callconv/x86-win32-fast-ms  unsigned-int "DC_CALL_C_X86_WIN32_FAST_MS")
(define-foreign-variable callconv/x86-win32-fast-gnu unsigned-int "DC_CALL_C_X86_WIN32_FAST_GNU")
(define-foreign-variable callconv/x86-win32-this-ms  unsigned-int "DC_CALL_C_X86_WIN32_THIS_MS")
(define-foreign-variable callconv/x86-win32-this-gnu unsigned-int "DC_CALL_C_X86_WIN32_THIS_GNU")
(define-foreign-variable callconv/x64-win64          unsigned-int "DC_CALL_C_X64_WIN64")
(define-foreign-variable callconv/x64-sysv           unsigned-int "DC_CALL_C_X64_SYSV")
(define-foreign-variable callconv/ppc32-darwin       unsigned-int "DC_CALL_C_PPC32_DARWIN")
(define-foreign-variable callconv/ppc32-osx          unsigned-int "DC_CALL_C_PPC32_OSX")
(define-foreign-variable callconv/arm-arm-eabi       unsigned-int "DC_CALL_C_ARM_ARM_EABI")
(define-foreign-variable callconv/arm-thumb-eabi     unsigned-int "DC_CALL_C_ARM_THUMB_EABI")
(define-foreign-variable callconv/mips32-eabi        unsigned-int "DC_CALL_C_MIPS32_EABI")
(define-foreign-variable callconv/mips32-pspsdk      unsigned-int "DC_CALL_C_MIPS32_PSPSDK")
(define-foreign-variable callconv/ppc32-sysv         unsigned-int "DC_CALL_C_PPC32_SYSV")
(define-foreign-variable callconv/ppc32-linux        unsigned-int "DC_CALL_C_PPC32_LINUX")
(define-foreign-variable callconv/arm-arm            unsigned-int "DC_CALL_C_ARM_ARM")
(define-foreign-variable callconv/arm-thumb          unsigned-int "DC_CALL_C_ARM_THUMB")
(define-foreign-variable callconv/mips32-o32         unsigned-int "DC_CALL_C_MIPS32_O32")
(define-foreign-variable callconv/mips64-n32         unsigned-int "DC_CALL_C_MIPS64_N32")
(define-foreign-variable callconv/mips63-n64         unsigned-int "DC_CALL_C_MIPS64_N64")
(define-foreign-variable callconv/x86-plan9          unsigned-int "DC_CALL_C_X86_PLAN9")
(define-foreign-variable callconv/sparc32            unsigned-int "DC_CALL_C_SPARC32")
(define-foreign-variable callconv/sparc64            unsigned-int "DC_CALL_C_SPARC64")
(define-foreign-variable callconv/sys-default        unsigned-int "DC_CALL_SYS_DEFAULT")
(define-foreign-variable callconv/x86-int80h-linux   unsigned-int "DC_CALL_SYS_X86_INT80H_LINUX")
(define-foreign-variable callconv/int80h-bsd         unsigned-int "DC_CALL_SYS_X86_INT80H_BSD")

(define-foreign-variable default/alignment      unsigned-int "DEFAULT_ALIGNMENT")
(define-foreign-variable error/none             unsigned-int "DC_ERROR_NONE")
(define-foreign-variable error/unsupported-mode unsigned-int "DC_ERROR_UNSUPPORTED_MODE")


(define make-vm
  (foreign-lambda dyncall-vm dcNewCallVM dyncall-size))
(define free-vm
  (foreign-lambda void dcFree dyncall-vm))

(define vm-reset
  (foreign-lambda void dcReset dyncall-vm))
(define vm-mode
  (foreign-lambda void dcMode dyncall-vm dyncall-int))

(define vm-bool-arg
  (foreign-lambda void dcArgBool     dyncall-vm dyncall-bool))
(define vm-char-arg
  (foreign-lambda void dcArgChar     dyncall-vm dyncall-char))
(define vm-short-arg
  (foreign-lambda void dcArgShort    dyncall-vm dyncall-short))
(define vm-int-arg
  (foreign-lambda void dcArgInt      dyncall-vm dyncall-int))
(define vm-long-arg
  (foreign-lambda void dcArgLong     dyncall-vm dyncall-long))
(define vm-long-long-arg
  (foreign-lambda void dcArgLongLong dyncall-vm dyncall-longlong))
(define vm-float-arg
  (foreign-lambda void dcArgFloat    dyncall-vm dyncall-float))
(define vm-double-arg
  (foreign-lambda void dcArgDouble   dyncall-vm dyncall-double))
(define vm-pointer-arg
  (foreign-lambda void dcArgPointer  dyncall-vm dyncall-pointer))
(define vm-struct-arg
  (foreign-lambda void dcArgStruct   dyncall-vm dyncall-struct dyncall-pointer))

(define vm-call-void
  (foreign-lambda void             dcCallVoid     dyncall-vm dyncall-pointer))
(define vm-call-bool
  (foreign-lambda dyncall-bool     dcCallBool     dyncall-vm dyncall-pointer))
(define vm-call-char
  (foreign-lambda dyncall-char     dcCallChar     dyncall-vm dyncall-pointer))
(define vm-call-short
  (foreign-lambda dyncall-short    dcCallShort    dyncall-vm dyncall-pointer))
(define vm-call-int
  (foreign-lambda dyncall-int      dcCallInt      dyncall-vm dyncall-pointer))
(define vm-call-long
  (foreign-lambda dyncall-long     dcCallLong     dyncall-vm dyncall-pointer))
(define vm-call-long-long
  (foreign-lambda dyncall-longlong dcCallLongLong dyncall-vm dyncall-pointer))
(define vm-call-float
  (foreign-lambda dyncall-float    dcCallFloat    dyncall-vm dyncall-pointer))
(define vm-call-double
  (foreign-lambda dyncall-double   dcCallDouble   dyncall-vm dyncall-pointer))
(define vm-call-pointer
  (foreign-lambda dyncall-pointer  dcCallPointer  dyncall-vm dyncall-pointer))
(define vm-call-struct
  (foreign-lambda void              dcCallStruct   dyncall-vm dyncall-pointer dyncall-struct dyncall-pointer))

(define struct-define
  (foreign-lambda dyncall-struct dcDefineStruct    c-string))
(define make-struct
  (foreign-lambda dyncall-struct dcNewStruct       dyncall-size dyncall-int))
(define free-struct
  (foreign-lambda void           dcFreeStruct      dyncall-struct))
(define struct-field
  (foreign-lambda void           dcStructField     dyncall-struct dyncall-int dyncall-int dyncall-size))
(define struct-sub
  (foreign-lambda void           dcSubStruct       dyncall-struct dyncall-size dyncall-int dyncall-size))
(define struct-close
  (foreign-lambda void           dcCloseStruct     dyncall-struct))
(define struct-size
  (foreign-lambda dyncall-size   dcStructSize      dyncall-struct))


(define dl-load-library
  (foreign-lambda dynload-lib dlLoadLibrary c-string))
(define dl-free-library
  (foreign-lambda void        dlFreeLibrary dynload-lib))
(define dl-find-symbol
  (foreign-lambda c-pointer   dlFindSymbol  dynload-lib c-string))

(define dl-syms-init 
  (foreign-lambda dynload-syms dlSymsInit          c-string))
(define dl-syms-cleanup
  (foreign-lambda void         dlSymsCleanup       dynload-syms))
(define dl-syms-count
  (foreign-lambda int          dlSymsCount         dynload-syms))
(define dl-syms-name
  (foreign-lambda c-string     dlSymsName          dynload-syms int))
(define dl-syms-name-from-value
  (foreign-lambda c-string     dlSymsNameFromValue dynload-syms c-pointer))

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
	   (%vm-call-void (r 'vm-call-void))
	   (%vm-call-bool (r 'vm-call-bool))
	   (%vm-call-char (r 'vm-call-char))
	   (%vm-call-short (r 'vm-call-short))
	   (%vm-call-int (r 'vm-call-int))
	   (%vm-call-long (r 'vm-call-long))
	   (%vm-call-longlong (r 'vm-call-longlong))
	   (%vm-call-float (r 'vm-call-float))
	   (%vm-call-double (r 'vm-call-double))
	   (%vm-call-pointer (r 'vm-call-pointer)))

       `(,%let ((vm (,%make-vm ,(length arg-map))))
	  (,%vm-mode vm 0) (,%vm-reset vm)
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
		       ((c-pointer) `(,%vm-pointer-arg  vm ,value)))))
		 arg-map)
	  (,%let ((return-value
		 ,(case return-type
		    ((void)      `(,%vm-call-void     vm ,func-ptr))
		    ((bool)      `(,%vm-call-bool     vm ,func-ptr))
		    ((char)      `(,%vm-call-char     vm ,func-ptr))
		    ((short)     `(,%vm-call-short    vm ,func-ptr))
		    ((int)       `(,%vm-call-int      vm ,func-ptr))
		    ((long)      `(,%vm-call-long     vm ,func-ptr))
		    ((longlong)  `(,%vm-call-longlong vm ,func-ptr))
		    ((float)     `(,%vm-call-float    vm ,func-ptr))
		    ((double)    `(,%vm-call-double   vm ,func-ptr))
		    ((c-pointer) `(,%vm-call-pointer  vm ,func-ptr)))))
	    (free-vm vm)
	    return-value)))))))

(define-syntax dyncall-lambda
  (er-macro-transformer
   (lambda (x r c)
     (let ((return-type (cadr x))
	   (func-ptr (caddr x))
	   (arg-types (cdddr x))
	   
	   (%let  (r 'let))
	   (%lambda (r 'lambda))
	   (%dyncall (r 'dyncall)))

       (let* ((arg-names (map (lambda (i) (string->symbol (format "a~A" i))) (iota (length arg-types))))
	      (arg-map (map (lambda (type name) (type name)) arg-types arg-names)))
	 `(,%let ((ptr ,func-ptr))
	    (,%lambda ,arg-names
	      (dyncall ,return-type ptr ,@arg-map))))))))
