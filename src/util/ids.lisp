(in-package #:workbench)

(defun make-id ()
  "Temporary starter ID generator. Replace later with something stronger."
  (format nil "~36R" (random most-positive-fixnum)))
