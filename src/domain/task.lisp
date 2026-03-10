(in-package #:workbench)

(defclass task (entity)
  ((project-id :initarg :project-id :accessor task-project-id)
   (title :initarg :title :accessor task-title)
   (description :initarg :description :accessor task-description :initform "")
   (status :initarg :status :accessor task-status :initform :open)
   (priority :initarg :priority :accessor task-priority :initform :normal)
   (due-date :initarg :due-date :accessor task-due-date :initform nil)
   (assignee-id :initarg :assignee-id :accessor task-assignee-id :initform nil)))

(defgeneric complete-task (task user))

(defmethod validate ((obj task))
  (and (task-project-id obj)
       (task-title obj)
       t))

(defmethod complete-task ((obj task) (user user))
  (declare (ignore user))
  (setf (task-status obj) :done)
  (touch obj)
  obj)
