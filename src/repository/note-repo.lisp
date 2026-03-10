(in-package #:workbench)

(defun row-to-note (row)
  "Convert a database row plist to a project-note instance."
  (when row
    (make-instance 'project-note
                   :id (getf row :|id|)
                   :project-id (getf row :|project_id|)
                   :user-id (getf row :|user_id|)
                   :body (getf row :|body|)
                   :created-at (parse-timestamp (getf row :|created_at|))
                   :updated-at (parse-timestamp (getf row :|updated_at|)))))

(defun list-notes-for-project (project-id)
  "Return all notes for a given project, newest first."
  (let ((result (execute-sql
                 "SELECT * FROM project_notes WHERE project_id = ? ORDER BY created_at DESC"
                 (list project-id))))
    (mapcar #'row-to-note (fetch-all result))))

(defun find-note-by-id (id)
  "Find a note by ID. Returns a project-note instance or NIL."
  (let ((result (execute-sql "SELECT * FROM project_notes WHERE id = ?" (list id))))
    (row-to-note (fetch-one result))))

(defun save-note (note)
  "Insert or replace a note record in the database."
  (validate note)
  (execute-sql
   "INSERT OR REPLACE INTO project_notes (id, project_id, user_id, body, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?)"
   (list (entity-id note)
         (note-project-id note)
         (note-user-id note)
         (note-body note)
         (format-timestamp (created-at note))
         (format-timestamp (updated-at note))))
  note)
