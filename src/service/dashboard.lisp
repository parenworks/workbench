(in-package #:workbench)

(defun count-open-projects ()
  "Return the count of projects with active status."
  (length (list-projects :status :active)))

(defun dashboard-summary ()
  "Aggregate dashboard data: open projects, overdue tasks, recent activity, and recently updated projects."
  (list :open-projects (count-open-projects)
        :overdue-tasks (list-overdue-tasks)
        :recent-activity (list-recent-activity :limit 10)
        :recent-projects (list-projects :status :active)))
