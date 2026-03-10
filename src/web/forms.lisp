(in-package #:workbench)

(defun validate-login-form (email password)
  "Validate login form fields. Returns an error string or NIL."
  (cond
    ((or (null email) (string= email "")) "Email is required.")
    ((or (null password) (string= password "")) "Password is required.")
    (t nil)))

(defun validate-client-form (name)
  "Validate client form fields. Returns an error string or NIL."
  (cond
    ((or (null name) (string= name "")) "Client name is required.")
    (t nil)))

(defun validate-project-form (name slug client-id)
  "Validate project form fields. Returns an error string or NIL."
  (cond
    ((or (null name) (string= name "")) "Project name is required.")
    ((or (null slug) (string= slug "")) "Project slug is required.")
    ((or (null client-id) (string= client-id "")) "Client is required.")
    (t nil)))

(defun validate-task-form (title)
  "Validate task form fields. Returns an error string or NIL."
  (cond
    ((or (null title) (string= title "")) "Task title is required.")
    (t nil)))

(defun validate-note-form (body)
  "Validate note form fields. Returns an error string or NIL."
  (cond
    ((or (null body) (string= body "")) "Note body is required.")
    (t nil)))
