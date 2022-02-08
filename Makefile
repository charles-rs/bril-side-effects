LISP ?= sbcl

build:
	$(LISP) --load lvntdce.asd \
		--eval '(ql:quickload :lvntdce)' \
			--eval '(asdf:make :lvntdce)' \
			--eval '(quit)'
