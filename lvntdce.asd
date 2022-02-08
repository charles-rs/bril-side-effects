;;;; brillisp.asd

(asdf:defsystem #:lvntdce
  :description "6120 A2"
  :author "Charles Sherk <cs897@cornell.edu"
  :license  "MIT?"
  :version "0.0.1"
  :serial t
  :pathname "src"
  :build-operation "program-op"
  :build-pathname "lvntdce.exe"
  :entry-point "lvntdce:main"
  :depends-on (#:cl-json #:alexandria)
  :components ((:file "package")
	       (:file "utils")
	       (:file "gdce")
	       (:file "cfg")
               (:file "lvntdce")))
