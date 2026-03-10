(in-package #:workbench)

(defun create-task (&key project-id title description priority due-date assignee-id user)
  "Create and persist a new task, recording an activity event. Returns the task instance."
  (let ((task (make-instance 'task
                             :project-id project-id
                             :title title
                             :description (or description "")
                             :priority (or priority :normal)
                             :due-date due-date
                             :assignee-id assignee-id)))
    (save-task task)
    (when user
      (let ((project (find-project-by-id project-id)))
        (when project
          (save-activity-event
           (record-event project user :task-added
                         :data (format nil "Task '~A' added" title))))))
    task))

(defun update-task-by-id (id &key title description priority due-date assignee-id status user)
  "Update an existing task's fields and persist. Returns the updated task or NIL."
  (let ((task (find-task-by-id id)))
    (when task
      (when title (setf (task-title task) title))
      (when description (setf (task-description task) description))
      (when priority (setf (task-priority task) priority))
      (when due-date (setf (task-due-date task) due-date))
      (when status (setf (task-status task) status))
      (when assignee-id
        (let ((old-assignee (task-assignee-id task)))
          (setf (task-assignee-id task) assignee-id)
          (when (and user (not (equal old-assignee assignee-id)))
            (let ((project (find-project-by-id (task-project-id task)))
                  (assignee (find-user-by-id assignee-id)))
              (when project
                (save-activity-event
                 (record-event project user :task-assigned
                               :data (format nil "Task '~A' assigned to ~A"
                                             (task-title task)
                                             (if assignee (display-name assignee) "unknown")))))))))
      (touch task)
      (save-task task)
      task)))

(defun get-task-detail (id)
  "Return a task with its associated project and assignee as a plist."
  (let ((task (find-task-by-id id)))
    (when task
      (list :task task
            :project (find-project-by-id (task-project-id task))
            :assignee (when (task-assignee-id task)
                        (find-user-by-id (task-assignee-id task)))
            :all-users (list-users)))))

(defun complete-task-by-id (id user)
  "Mark a task as done by ID. Records an activity event. Returns the task or NIL."
  (let ((task (find-task-by-id id)))
    (when task
      (complete-task task user)
      (save-task task)
      (let ((project (find-project-by-id (task-project-id task))))
        (when project
          (save-activity-event
           (record-event project user :task-completed
                         :data (format nil "Task '~A' completed" (task-title task))))))
      task)))

(defun reopen-task-by-id (id user)
  "Reopen a completed task by ID. Returns the task or NIL."
  (let ((task (find-task-by-id id)))
    (when task
      (setf (task-status task) :open)
      (touch task)
      (save-task task)
      (let ((project (find-project-by-id (task-project-id task))))
        (when project
          (save-activity-event
           (record-event project user :task-reopened
                         :data (format nil "Task '~A' reopened" (task-title task))))))
      task)))

(defun my-tasks (user)
  "Return all open tasks assigned to the given user."
  (list-tasks-for-user (entity-id user)))
