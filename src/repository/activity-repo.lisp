(in-package #:workbench)

(defun row-to-activity-event (row)
  "Convert a database row plist to an activity-event instance."
  (when row
    (make-instance 'activity-event
                   :id (getf row :|id|)
                   :project-id (getf row :|project_id|)
                   :user-id (getf row :|user_id|)
                   :event-type (intern (string-upcase (getf row :|event_type|)) :keyword)
                   :event-data (getf row :|event_data|)
                   :created-at (parse-timestamp (getf row :|created_at|)))))

(defun list-activity-for-project (project-id)
  "Return all activity events for a given project, newest first."
  (let ((result (execute-sql
                 "SELECT * FROM activity_events WHERE project_id = ? ORDER BY created_at DESC"
                 (list project-id))))
    (mapcar #'row-to-activity-event (fetch-all result))))

(defun list-recent-activity (&key (limit 20))
  "Return the most recent activity events across all projects."
  (let ((result (execute-sql
                 (format nil "SELECT * FROM activity_events ORDER BY created_at DESC LIMIT ~D" limit))))
    (mapcar #'row-to-activity-event (fetch-all result))))

(defun save-activity-event (event)
  "Insert an activity event record in the database."
  (validate event)
  (execute-sql
   "INSERT INTO activity_events (id, project_id, user_id, event_type, event_data, created_at)
    VALUES (?, ?, ?, ?, ?, ?)"
   (list (entity-id event)
         (event-project-id event)
         (event-user-id event)
         (string-downcase (symbol-name (event-type event)))
         (event-data event)
         (format-timestamp (created-at event))))
  event)
