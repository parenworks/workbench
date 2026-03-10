(defpackage #:workbench
  (:use #:cl)
  (:import-from #:local-time
                #:now)
  (:import-from #:cl-who
                #:with-html-output
                #:with-html-output-to-string
                #:htm
                #:fmt
                #:str
                #:esc)
  (:export
   ;; core
   #:start-workbench
   #:stop-workbench
   #:seed-demo-data

   ;; utilities
   #:make-id
   #:timestamp-now
   #:format-timestamp
   #:parse-timestamp
   #:hash-password

   ;; base entity
   #:entity
   #:entity-id
   #:created-at
   #:updated-at
   #:validate
   #:touch
   #:serialize
   #:display-name
   #:can-view-p
   #:can-edit-p

   ;; domain classes
   #:user
   #:client
   #:project
   #:task
   #:project-note
   #:activity-event
   #:attachment
   #:session

   ;; accessors
   #:user-email
   #:password-hash
   #:user-role
   #:client-name
   #:contact-name
   #:contact-email
   #:client-notes
   #:project-client-id
   #:project-name
   #:project-slug
   #:project-status
   #:project-description
   #:task-project-id
   #:task-title
   #:task-description
   #:task-status
   #:task-priority
   #:task-due-date
   #:task-assignee-id
   #:note-project-id
   #:note-user-id
   #:note-body
   #:event-project-id
   #:event-user-id
   #:event-type
   #:event-data
   #:attachment-project-id
   #:attachment-filename
   #:attachment-storage-path
   #:attachment-mime-type
   #:session-user-id
   #:session-token
   #:session-expires-at

   ;; domain actions
   #:add-note
   #:add-task
   #:complete-task
   #:record-event
   #:archive-project
   #:project-summary

   ;; database
   #:connect-db
   #:disconnect-db
   #:initialize-schema

   ;; repository
   #:find-user-by-email
   #:find-user-by-id
   #:save-user
   #:list-users
   #:list-clients
   #:find-client-by-id
   #:save-client
   #:delete-client
   #:search-clients
   #:list-projects
   #:find-project-by-id
   #:find-project-by-slug
   #:list-projects-for-client
   #:save-project
   #:delete-project
   #:search-projects
   #:list-tasks-for-project
   #:find-task-by-id
   #:list-overdue-tasks
   #:list-tasks-for-user
   #:save-task
   #:delete-task
   #:list-notes-for-project
   #:find-note-by-id
   #:save-note
   #:list-activity-for-project
   #:list-recent-activity
   #:save-activity-event
   #:find-session-by-token
   #:save-session
   #:delete-session-by-token
   #:delete-expired-sessions

   ;; services
   #:authenticate-user
   #:validate-session
   #:logout-session
   #:register-user
   #:create-client
   #:update-client
   #:get-client-with-projects
   #:create-project
   #:update-project
   #:archive-project-by-id
   #:get-project-detail
   #:create-task
   #:update-task-by-id
   #:get-task-detail
   #:complete-task-by-id
   #:reopen-task-by-id
   #:my-tasks
   #:update-user-by-id
   #:dashboard-summary

   ;; web
   #:start-server
   #:stop-server
   #:generate-css
   #:generate-js
   #:define-routes
   #:register-dispatchers))
