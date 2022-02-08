;; gdce.lisp
(in-package #:lvntdce)


(defun used (function)
  "returns a hashmap with all of the variables that are used in FUNCTION"
  (let ((tbl (make-hash-table :test 'equal)))
    (loop :for instr in (aget :instrs function)
	  :do (collect-used instr tbl))
    tbl))

(defun collect-used (instr tbl)
  "puts the args of INSTR into TBL"
  (loop :for a in (aget :args instr)
	:do (setf (gethash a tbl) t)))

(defun dead-p (instr tbl)
  (let ((dest (aget :dest instr)))
    (if dest
	(not (gethash dest tbl))
	nil)))

(defun remove-if-dead (function)
  (let ((removed? nil)
	(tbl (used function)))
    (values
     (areplace :instrs
	       (remove-if (lambda (instr) (let ((dead (dead-p instr tbl)))
				       (setf removed? (or removed? dead))
				       dead)) (aget :instrs function))
	       function)
     removed?)))

(defun undeadify (function)
  (multiple-value-bind (new killed)
      (remove-if-dead function)
    (loop :while killed
	  :do (multiple-value-setq (new killed)
		(remove-if-dead new)))
    new))

(defun undeadify-program (program)
  (areplace :functions (mapcar #'undeadify (aget :functions program))
	    program))
