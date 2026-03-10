(in-package #:workbench)

(defun create-project (&key client-id name slug description user)
  "Create and persist a new project, recording an activity event. Returns the project instance."
  (let ((project (make-instance 'project
                                :client-id client-id
                                :name name
                                :slug slug
                                :description description)))
    (save-project project)
    (when user
      (save-activity-event
       (record-event project user :project-created
                     :data (format nil "Project '~A' created" name))))
    project))

(defun update-project (id &key name slug description status user)
  "Update an existing project's fields and persist. Returns the updated project or NIL."
  (let ((project (find-project-by-id id)))
    (when project
      (let ((old-status (project-status project)))
        (when name (setf (project-name project) name))
        (when slug (setf (project-slug project) slug))
        (when description (setf (project-description project) description))
        (when status (setf (project-status project) status))
        (touch project)
        (save-project project)
        (when (and user status (not (eq old-status status)))
          (save-activity-event
           (record-event project user :status-changed
                         :data (format nil "Status changed from ~A to ~A"
                                       (string-downcase (symbol-name old-status))
                                       (string-downcase (symbol-name status)))))))
      project)))

(defun archive-project-by-id (id user)
  "Archive a project by ID. Records an activity event. Returns the project or NIL."
  (let ((project (find-project-by-id id)))
    (when project
      (archive-project project user)
      (save-project project)
      (save-activity-event
       (record-event project user :project-archived
                     :data (format nil "Project '~A' archived" (project-name project))))
      project)))

(defun get-project-detail (id)
  "Return a project with all its associated data as a plist."
  (let ((project (find-project-by-id id)))
    (when project
      (list :project project
            :client (find-client-by-id (project-client-id project))
            :tasks (list-tasks-for-project id)
            :notes (list-notes-for-project id)
            :activity (list-activity-for-project id)))))
