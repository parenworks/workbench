(in-package #:workbench)

(defun row-to-user (row)
  "Convert a database row plist to a user instance."
  (when row
    (make-instance 'user
                   :id (getf row :|id|)
                   :email (getf row :|email|)
                   :password-hash (getf row :|password_hash|)
                   :display-name (getf row :|display_name|)
                   :role (intern (string-upcase (getf row :|role|)) :keyword)
                   :created-at (parse-timestamp (getf row :|created_at|))
                   :updated-at (parse-timestamp (getf row :|updated_at|)))))

(defun find-user-by-email (email)
  "Find a user by email address. Returns a user instance or NIL."
  (let ((result (execute-sql "SELECT * FROM users WHERE email = ?" (list email))))
    (row-to-user (fetch-one result))))

(defun find-user-by-id (id)
  "Find a user by ID. Returns a user instance or NIL."
  (let ((result (execute-sql "SELECT * FROM users WHERE id = ?" (list id))))
    (row-to-user (fetch-one result))))

(defun save-user (user)
  "Insert or replace a user record in the database."
  (validate user)
  (execute-sql
   "INSERT OR REPLACE INTO users (id, email, password_hash, display_name, role, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?)"
   (list (entity-id user)
         (user-email user)
         (password-hash user)
         (display-name user)
         (string-downcase (symbol-name (user-role user)))
         (format-timestamp (created-at user))
         (format-timestamp (updated-at user))))
  user)

(defun list-users ()
  "Return all users."
  (let ((result (execute-sql "SELECT * FROM users ORDER BY display_name")))
    (mapcar #'row-to-user (fetch-all result))))
