(in-package #:workbench)

(defun start-workbench ()
  "Initialize the database, generate assets, define routes, and start the web server."
  (format t "~&Starting ~A...~%" *app-name*)
  (format t "~&Database path: ~A~%" *db-path*)
  (connect-db)
  (initialize-schema)
  (delete-expired-sessions)
  (generate-css)
  (generate-js)
  (define-routes)
  (register-dispatchers)
  (start-server)
  (format t "~&~A is ready at http://localhost:~D/~%" *app-name* *server-port*)
  (values))

(defun stop-workbench ()
  "Stop the web server and close the database connection."
  (stop-server)
  (disconnect-db)
  (format t "~&~A stopped.~%" *app-name*)
  (values))

(defun seed-demo-data ()
  "Populate the database with sample data for development and demo purposes."
  (format t "~&Seeding demo data...~%")

  ;; Create admin user
  (let ((admin (register-user :email "admin@workbench.local"
                              :password "admin"
                              :display-name "Admin"
                              :role :admin)))

    ;; Create some clients
    (let ((client-a (create-client :name "Acme Corp"
                                   :contact-name "Alice Smith"
                                   :contact-email "alice@acme.example"
                                   :notes "Primary consulting client."))
          (client-b (create-client :name "Bright Ideas Ltd"
                                   :contact-name "Bob Jones"
                                   :contact-email "bob@brightideas.example"
                                   :notes "Design and branding work.")))

      ;; Create projects for Acme
      (let ((proj-1 (create-project :client-id (entity-id client-a)
                                    :name "Website Redesign"
                                    :slug "acme-website-redesign"
                                    :description "Full redesign of the Acme corporate site."
                                    :user admin))
            (proj-2 (create-project :client-id (entity-id client-b)
                                    :name "Brand Guidelines"
                                    :slug "bright-brand-guidelines"
                                    :description "Create comprehensive brand guidelines document."
                                    :user admin)))

        ;; Add tasks to Website Redesign
        (create-task :project-id (entity-id proj-1)
                     :title "Gather requirements"
                     :priority :high
                     :user admin)
        (create-task :project-id (entity-id proj-1)
                     :title "Create wireframes"
                     :priority :normal
                     :user admin)
        (create-task :project-id (entity-id proj-1)
                     :title "Design homepage mockup"
                     :priority :normal
                     :due-date (local-time:adjust-timestamp (timestamp-now)
                                 (offset :day 7))
                     :user admin)

        ;; Add tasks to Brand Guidelines
        (create-task :project-id (entity-id proj-2)
                     :title "Audit existing brand assets"
                     :priority :high
                     :user admin)
        (create-task :project-id (entity-id proj-2)
                     :title "Define colour palette"
                     :priority :normal
                     :user admin)

        ;; Add notes
        (let ((note-1 (add-note proj-1 admin "Kickoff meeting scheduled for next Monday.")))
          (save-note note-1))
        (let ((note-2 (add-note proj-1 admin "Client prefers a minimalist look.")))
          (save-note note-2))
        (let ((note-3 (add-note proj-2 admin "Bob wants the guidelines done before the trade show.")))
          (save-note note-3)))))

  (format t "~&Demo data seeded successfully.~%")
  (values))
