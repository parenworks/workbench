(asdf:defsystem "workbench"
  :description "Workbench - lightweight internal operations system"
  :author "Glenn Thompson"
  :license "MIT"
  :version "0.1.0"
  :serial t
  :depends-on (:local-time
               :ironclad
               :bordeaux-threads
               :cl-dbi
               :dbd-sqlite3
               :hunchentoot
               :cl-who
               :lass
               :parenscript)
  :components ((:file "src/packages")
               (:file "src/config")
               (:file "src/core")
               (:file "src/util/time")
               (:file "src/util/ids")
               (:file "src/util/crypto")
               (:file "src/domain/entity")
               (:file "src/domain/user")
               (:file "src/domain/client")
               (:file "src/domain/project")
               (:file "src/domain/task")
               (:file "src/domain/note")
               (:file "src/domain/activity")
               (:file "src/domain/attachment")
               (:file "src/domain/session")
               (:file "src/repository/db")
               (:file "src/repository/user-repo")
               (:file "src/repository/client-repo")
               (:file "src/repository/project-repo")
               (:file "src/repository/task-repo")
               (:file "src/repository/note-repo")
               (:file "src/repository/activity-repo")
               (:file "src/repository/session-repo")
               (:file "src/service/auth")
               (:file "src/service/clients")
               (:file "src/service/projects")
               (:file "src/service/tasks")
               (:file "src/service/dashboard")
               (:file "src/web/server")
               (:file "src/web/middleware")
               (:file "src/web/layout")
               (:file "src/web/styles")
               (:file "src/web/scripts")
               (:file "src/web/forms")
               (:file "src/web/views")
               (:file "src/web/routes")))
