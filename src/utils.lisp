;; utils.lisp

(in-package #:lvntdce)

(defun aget (item list)
  (cdr (assoc item list)))

(defun areplace (key val lst)
  (let* ((replaced? nil)
	 (lst
	   (substitute-if (cons key val)
			  (lambda (pr) (and (eql (car pr) key)
				       (setf replaced? t))) lst)))
    (if replaced? lst (cons (cons key val) lst))))
