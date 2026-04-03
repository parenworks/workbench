;;;; Workbench Startup Script
;;;;
;;;; Load this file to start Workbench.
;;;; Usage: (load "start.lisp")

(in-package #:cl-user)

;;; Ensure Quicklisp is available
(unless (find-package :quicklisp)
  (error "Quicklisp is required. Please install Quicklisp first."))

;;; Register Workbench with ASDF
(format t "~&Loading Workbench...~%")
(pushnew (make-pathname :directory (pathname-directory *load-truename*))
         asdf:*central-registry*
         :test #'equal)

(ql:quickload "workbench" :silent t)

;;; Start the application
(format t "~&~%")
(format t "~&========================================~%")
(format t "~&  Workbench — Operations System~%")
(format t "~&========================================~%")
(format t "~&~%")

(workbench:start-workbench)

;;; Seed demo data on first run if database is empty
(handler-case
    (let ((db-path (merge-pathnames "data/workbench.sqlite"
                                    (asdf:system-source-directory "workbench"))))
      (unless (probe-file db-path)
        (format t "~&First run detected — seeding demo data...~%")
        (workbench:seed-demo-data)))
  (error (c)
    (format t "~&Note: Could not check for demo data: ~A~%" c)))

(format t "~&~%")
(format t "~&Workbench is running at http://localhost:~D/~%" workbench::*server-port*)
(format t "~&Login: admin@workbench.local / admin~%")
(format t "~&~%")
(format t "~&To stop: (workbench:stop-workbench)~%")
(format t "~&========================================~%")
