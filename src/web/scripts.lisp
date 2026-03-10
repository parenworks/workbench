(in-package #:workbench)

(defun generate-js ()
  "Generate the application JavaScript using Parenscript and write it to static/js/workbench.js."
  (let ((js-path (merge-pathnames "static/js/workbench.js"
                                  (asdf:system-source-directory "workbench"))))
    (ensure-directories-exist js-path)
    (with-open-file (out js-path :direction :output :if-exists :supersede)
      (write-string (compile-scripts) out))
    (format t "~&JS written to ~A~%" js-path)
    js-path))

(defun compile-scripts ()
  "Compile all Parenscript to a JavaScript string."
  (concatenate
   'string
   (ps:ps
    (defun setup-flash-dismiss ()
      (let ((flash (ps:chain document (query-selector ".flash-message"))))
        (when flash
          (set-timeout (lambda ()
                         (setf (ps:@ flash style opacity) "0")
                         (set-timeout (lambda ()
                                        (setf (ps:@ flash style display) "none"))
                                      300))
                       5000)))))

   (ps:ps
    (defun confirm-action (message)
      (ps:chain window (confirm message))))

   (ps:ps
    (defun setup-autofocus ()
      (let ((input (ps:chain document (query-selector "form .form-input, form .form-textarea"))))
        (when input
          (ps:chain input (focus))))))

   (ps:ps
    (defun setup-search ()
      (let ((search-input (ps:chain document (query-selector ".search-input"))))
        (when search-input
          (ps:chain search-input
                    (add-event-listener "input"
                                        (lambda (e)
                                          (let ((query (ps:chain (ps:@ e target value) (to-lower-case)))
                                                (rows (ps:chain document (query-selector-all "table tbody tr"))))
                                            (ps:chain rows (for-each
                                                            (lambda (row)
                                                              (let ((text (ps:chain (ps:@ row text-content) (to-lower-case))))
                                                                (setf (ps:@ row style display)
                                                                      (if (ps:chain text (includes query))
                                                                          ""
                                                                          "none"))))))))))))))

   (ps:ps
    (defun setup-shortcuts ()
      (ps:chain document
                (add-event-listener "keydown"
                                    (lambda (e)
                                      (when (and (ps:@ e alt-key) (not (ps:@ e ctrl-key)))
                                        (cond
                                          ((equal (ps:@ e key) "d")
                                           (ps:chain e (prevent-default))
                                           (setf (ps:@ window location) "/"))
                                          ((equal (ps:@ e key) "c")
                                           (ps:chain e (prevent-default))
                                           (setf (ps:@ window location) "/clients"))
                                          ((equal (ps:@ e key) "p")
                                           (ps:chain e (prevent-default))
                                           (setf (ps:@ window location) "/projects"))
                                          ((equal (ps:@ e key) "t")
                                           (ps:chain e (prevent-default))
                                           (setf (ps:@ window location) "/my-tasks"))
                                          ((equal (ps:@ e key) "u")
                                           (ps:chain e (prevent-default))
                                           (setf (ps:@ window location) "/users"))
                                          ((equal (ps:@ e key) "/")
                                           (ps:chain e (prevent-default))
                                           (let ((search (ps:chain document (query-selector ".search-input"))))
                                             (when search
                                               (ps:chain search (focus))))))))))))

   (ps:ps
    (ps:chain document
              (add-event-listener "DOMContentLoaded"
                                  (lambda ()
                                    (setup-flash-dismiss)
                                    (setup-autofocus)
                                    (setup-search)
                                    (setup-shortcuts)))))))
