(in-package #:workbench)

(defvar *server* nil
  "The Hunchentoot acceptor instance.")

(defun start-server ()
  "Start the Hunchentoot web server on *server-port*."
  (when *server*
    (stop-server))
  (setf *server*
        (make-instance 'hunchentoot:easy-acceptor
                       :port *server-port*
                       :document-root (merge-pathnames "static/"
                                                       (asdf:system-source-directory "workbench"))))
  (hunchentoot:start *server*)
  (format t "~&Web server started on port ~D~%" *server-port*)
  *server*)

(defun stop-server ()
  "Stop the Hunchentoot web server."
  (when *server*
    (hunchentoot:stop *server*)
    (setf *server* nil)
    (format t "~&Web server stopped.~%")))
