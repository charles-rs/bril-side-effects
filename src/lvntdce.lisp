(in-package #:lvntdce)


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
  (encode-program (undeadify-program program)))

(defun encode-program (program &optional (out json:*json-output*))
  (json:with-object (out)
    (json:encode-object-member :functions
			       (aget :functions program) out)))
