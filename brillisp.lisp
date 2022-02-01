;;;; brillisp.lisp

(in-package #:brillisp)

(defparameter *these-are-pure* (make-hash-table :test 'equal))

(defun main ()
  (let ((inpt
	  (format nil "~{~A~^~%~}"
		  (loop :for line = (read-line *standard-input* nil)
			:while line
			:collect line))))
    (process-bril (json:decode-json-from-string inpt))))

(defun to-func-list (program)
  (cdar program))

(defun process-bril (program)
  (format t "~a~%" (mapcar #'func-has-side (to-func-list program))))

(defun aget (item list)
  (cdr (assoc item list)))

(defun contains-ptr (type-list)
  (print type-list)
  (reduce (lambda (acc type) (or acc (and (typep type 'cons) (eql :ptr (caar type)))))
	  type-list :initial-value nil))

(defun func-has-side (function)
  (let* ((name (cdr (assoc :name function)))
	 (instr-side
	   (reduce (lambda (a b) (or a b))
		   (cdr (assoc :instrs function))
		   :key #'instr-has-side))
	 (escape-side (contains-ptr (cons (aget :type function)
					  (mapcar (lambda (arg) (aget :type arg))
						  (aget :args function)))))
	 (result (or instr-side escape-side)))
    (when (not result)
      (setf (gethash name *these-are-pure*) t))
    (cons name result)))

(defun instr-has-side (instr)
  (alexandria:switch ((cdr (assoc :op instr)) :test (lambda (v lst) (member v lst :test 'equalp)))
    ('("ret" "add" "sub" "mul" "div" "const") nil)
    ('("eq" "lt" "gt" "le" "ge") nil)
    ('("call") (let ((func (cdr (assoc :funcs instr))))
		 (if (gethash func *these-are-pure*)
		     nil
		     t)))
    ('("print") t)
    ('("alloc" "free" "store" "load") nil)
    (t (error (format nil "invalid bril: ~a" (cdr (assoc :op instr)))))))
