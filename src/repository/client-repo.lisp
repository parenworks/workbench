(in-package #:workbench)

(defun row-to-client (row)
  "Convert a database row plist to a client instance."
  (when row
    (make-instance 'client
                   :id (getf row :|id|)
                   :name (getf row :|name|)
                   :contact-name (getf row :|contact_name|)
                   :contact-email (getf row :|contact_email|)
                   :notes (getf row :|notes|)
                   :created-at (parse-timestamp (getf row :|created_at|))
                   :updated-at (parse-timestamp (getf row :|updated_at|)))))

(defun list-clients ()
  "Return all clients ordered by name."
  (let ((result (execute-sql "SELECT * FROM clients ORDER BY name")))
    (mapcar #'row-to-client (fetch-all result))))

(defun find-client-by-id (id)
  "Find a client by ID. Returns a client instance or NIL."
  (let ((result (execute-sql "SELECT * FROM clients WHERE id = ?" (list id))))
    (row-to-client (fetch-one result))))

(defun save-client (client)
  "Insert or replace a client record in the database."
  (validate client)
  (execute-sql
   "INSERT OR REPLACE INTO clients (id, name, contact_name, contact_email, notes, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?)"
   (list (entity-id client)
         (client-name client)
         (contact-name client)
         (contact-email client)
         (client-notes client)
         (format-timestamp (created-at client))
         (format-timestamp (updated-at client))))
  client)

(defun delete-client (id)
  "Delete a client by ID."
  (execute-sql "DELETE FROM clients WHERE id = ?" (list id))
  t)

(defun search-clients (query)
  "Search clients by name or contact name."
  (let ((pattern (format nil "%~A%" query)))
    (let ((result (execute-sql
                   "SELECT * FROM clients WHERE name LIKE ? OR contact_name LIKE ? ORDER BY name"
                   (list pattern pattern))))
      (mapcar #'row-to-client (fetch-all result)))))
