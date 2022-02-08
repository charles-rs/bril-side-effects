;;; cfg.lisp
;;; a CFG is a map from labels => (code next-t &optional next-f)
(in-package #:lvntdce)

(defun label-p (insn)
  (not (not (assoc :label insn))))

(defun jmp-p (insn)
  (not (not (assoc :labels insn))))

(defun ret-p (insn)
  (equal "ret" (aget :op insn)))

(defun munch-block (insns &optional lbl acc)
	       "returns four values: first the label of this block and then
                the insns of this block, thirdly the followers of this block,
                and finally the unmunched instructions"
  (cond ((ret-p (car acc))
	 (values lbl (reverse acc) :ret insns))
	((jmp-p (car acc))
	 (values lbl (reverse acc) (aget :labels (car acc)) insns))
	((null insns) (values lbl (reverse acc) nil insns))
	((label-p (car insns))
	 (if lbl
	     (values lbl (reverse acc) (aget :label (car insns)) insns)
	     (munch-block (cdr insns) (aget :label (car insns)) (list (car insns)))))
	(T (munch-block (cdr insns) lbl (cons (car insns) acc)))))

(defun munch-useless (insns)
	       (cond ((null insns) nil)
		     ((label-p (car insns)) insns)
		     (t (munch-useless (cdr insns)))))

(defun to-cfg (insns)
  (let ((tbl (make-hash-table :test #'equal)))
    (labels ((helper (insns &optional lblorder)
	       (if insns
		   (let ((munched (munch-useless insns)))
		     (multiple-value-bind (from blk to rest)
			 (munch-block munched)
		       (setf (gethash from tbl) (cons blk to))
		       (helper rest (cons from lblorder))))
		   (values tbl (reverse lblorder)))))
      (multiple-value-bind (from blk to rest)
	  (munch-block insns :start)
	(setf (gethash from tbl) (cons blk to))
	(helper rest)))))

(defun listify (thing)
  (if (listp thing) thing (list thing)))

(defun cfg-to-dot (tbl &optional (out *standard-output*))
  (format out "digraph cfg {~%rankdir=LR~%")
  (loop :for k being the hash-keys of tbl
	:do (destructuring-bind (code &rest dests) (gethash k tbl)
	      (declare (ignore code))
	      (loop :for i in '("true" "false")
		    :for d in (listify dests)
		    :do (format t "~a -> ~a [label = ~a];~%"
				k d i))))
  (format out "}~%"))


(defun cfg-to-insns (tbl lblorder)
  (labels ((helper (order blocklist)
	     (cond ((null order) (reduce #'append (reverse blocklist)))
		   (T (destructuring-bind (code &rest dests)
			  (gethash (car order) tbl)
			(declare (ignore dests))
			(helper (cdr order) (cons code blocklist)))))))
    (destructuring-bind (code &rest dests)
	(gethash :start tbl)
      (declare (ignore dests))
      (helper lblorder (list code)))))

(defun apply-local-opt-fun (optimization function)
  (let ((insns (aget :instrs function)))
    (multiple-value-bind (tbl order) (to-cfg insns)
      (loop :for k being the hash-keys of tbl
	    :do (progn
		  (destructuring-bind (code &rest dests)
		      (gethash k tbl)
		      (setf (gethash k tbl)
			    (cons (funcall optimization code) dests)))))
      (areplace :instrs
		(cfg-to-insns tbl order)
		function))))

(defun apply-local-opt-prog (optimization program)
  (areplace :functions (mapcar (lambda (fun) (apply-local-opt-fun optimization fun))
			       (aget :functions program))
	    program))
