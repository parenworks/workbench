(in-package #:workbench)

(defun row-to-task (row)
  "Convert a database row plist to a task instance."
  (when row
    (make-instance 'task
                   :id (getf row :|id|)
                   :project-id (getf row :|project_id|)
                   :title (getf row :|title|)
                   :description (or (getf row :|description|) "")
                   :status (intern (string-upcase (getf row :|status|)) :keyword)
                   :priority (intern (string-upcase (getf row :|priority|)) :keyword)
                   :due-date (parse-timestamp (getf row :|due_date|))
                   :assignee-id (getf row :|assignee_id|)
                   :created-at (parse-timestamp (getf row :|created_at|))
                   :updated-at (parse-timestamp (getf row :|updated_at|)))))

(defun list-tasks-for-project (project-id)
  "Return all tasks for a given project."
  (let ((result (execute-sql
                 "SELECT * FROM tasks WHERE project_id = ? ORDER BY created_at DESC"
                 (list project-id))))
    (mapcar #'row-to-task (fetch-all result))))

(defun find-task-by-id (id)
  "Find a task by ID. Returns a task instance or NIL."
  (let ((result (execute-sql "SELECT * FROM tasks WHERE id = ?" (list id))))
    (row-to-task (fetch-one result))))

(defun list-overdue-tasks ()
  "Return all open tasks with a due date in the past."
  (let ((result (execute-sql
                 "SELECT * FROM tasks WHERE status = 'open' AND due_date IS NOT NULL AND due_date < ? ORDER BY due_date"
                 (list (format-timestamp (timestamp-now))))))
    (mapcar #'row-to-task (fetch-all result))))

(defun list-tasks-for-user (user-id)
  "Return all open tasks assigned to a given user, across all projects."
  (let ((result (execute-sql
                 "SELECT * FROM tasks WHERE assignee_id = ? AND status = 'open' ORDER BY due_date ASC, created_at DESC"
                 (list user-id))))
    (mapcar #'row-to-task (fetch-all result))))

(defun save-task (task)
  "Insert or replace a task record in the database."
  (validate task)
  (execute-sql
   "INSERT OR REPLACE INTO tasks (id, project_id, title, description, status, priority, due_date, assignee_id, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
   (list (entity-id task)
         (task-project-id task)
         (task-title task)
         (task-description task)
         (string-downcase (symbol-name (task-status task)))
         (string-downcase (symbol-name (task-priority task)))
         (when (task-due-date task) (format-timestamp (task-due-date task)))
         (task-assignee-id task)
         (format-timestamp (created-at task))
         (format-timestamp (updated-at task))))
  task)

(defun delete-task (id)
  "Delete a task by ID."
  (execute-sql "DELETE FROM tasks WHERE id = ?" (list id))
  t)
