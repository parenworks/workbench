(in-package #:workbench)

(defun row-to-project (row)
  "Convert a database row plist to a project instance."
  (when row
    (make-instance 'project
                   :id (getf row :|id|)
                   :client-id (getf row :|client_id|)
                   :name (getf row :|name|)
                   :slug (getf row :|slug|)
                   :status (intern (string-upcase (getf row :|status|)) :keyword)
                   :description (or (getf row :|description|) "")
                   :created-at (parse-timestamp (getf row :|created_at|))
                   :updated-at (parse-timestamp (getf row :|updated_at|)))))

(defun list-projects (&key status)
  "Return all projects, optionally filtered by status."
  (if status
      (let ((result (execute-sql
                     "SELECT * FROM projects WHERE status = ? ORDER BY updated_at DESC"
                     (list (string-downcase (symbol-name status))))))
        (mapcar #'row-to-project (fetch-all result)))
      (let ((result (execute-sql "SELECT * FROM projects ORDER BY updated_at DESC")))
        (mapcar #'row-to-project (fetch-all result)))))

(defun find-project-by-id (id)
  "Find a project by ID. Returns a project instance or NIL."
  (let ((result (execute-sql "SELECT * FROM projects WHERE id = ?" (list id))))
    (row-to-project (fetch-one result))))

(defun find-project-by-slug (slug)
  "Find a project by slug. Returns a project instance or NIL."
  (let ((result (execute-sql "SELECT * FROM projects WHERE slug = ?" (list slug))))
    (row-to-project (fetch-one result))))

(defun list-projects-for-client (client-id)
  "Return all projects belonging to a client."
  (let ((result (execute-sql
                 "SELECT * FROM projects WHERE client_id = ? ORDER BY updated_at DESC"
                 (list client-id))))
    (mapcar #'row-to-project (fetch-all result))))

(defun save-project (project)
  "Insert or replace a project record in the database."
  (validate project)
  (execute-sql
   "INSERT OR REPLACE INTO projects (id, client_id, name, slug, status, description, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
   (list (entity-id project)
         (project-client-id project)
         (project-name project)
         (project-slug project)
         (string-downcase (symbol-name (project-status project)))
         (project-description project)
         (format-timestamp (created-at project))
         (format-timestamp (updated-at project))))
  project)

(defun delete-project (id)
  "Delete a project by ID."
  (execute-sql "DELETE FROM projects WHERE id = ?" (list id))
  t)

(defun search-projects (query)
  "Search projects by name or description."
  (let ((pattern (format nil "%~A%" query)))
    (let ((result (execute-sql
                   "SELECT * FROM projects WHERE name LIKE ? OR description LIKE ? ORDER BY updated_at DESC"
                   (list pattern pattern))))
      (mapcar #'row-to-project (fetch-all result)))))
