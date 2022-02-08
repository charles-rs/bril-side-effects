LISP ?= sbcl

build:
	$(LISP) --load brillisp.asd \
		--eval '(ql:quickload :brillisp)' \
			--eval '(asdf:make :brillisp)' \
			--eval '(quit)'
