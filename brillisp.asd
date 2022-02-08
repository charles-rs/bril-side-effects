;;;; brillisp.asd

(asdf:defsystem #:brillisp
  :description "bril but lisp lmao"
  :author "Charles Sherk <cs897@cornell.edu"
  :license  "MIT?"
  :version "0.0.1"
  :serial t
  :build-operation "program-op"
  :build-pathname "side-effects.exe"
  :entry-point "brillisp:main"
  :depends-on (#:cl-json #:alexandria)
  :components ((:file "package")
               (:file "brillisp")))
