(in-package #:workbench)

(defvar *db* nil
  "Active database connection handle.")

(defun connect-db ()
  "Connect to the SQLite database at *db-path*. Creates the file if it does not exist."
  (ensure-directories-exist (pathname *db-path*))
  (setf *db* (dbi:connect :sqlite3 :database-name *db-path*))
  (format t "~&Connected to DB at ~A~%" *db-path*)
  *db*)

(defun disconnect-db ()
  "Disconnect from the active database."
  (when *db*
    (dbi:disconnect *db*)
    (setf *db* nil)
    (format t "~&Disconnected from DB~%")))

(defun ensure-db ()
  "Return the active DB connection, connecting if necessary."
  (or *db* (connect-db)))

(defun execute-sql (sql &optional params)
  "Execute a SQL statement with optional parameters. Returns the query result."
  (let* ((conn (ensure-db))
         (query (dbi:prepare conn sql)))
    (if params
        (dbi:execute query params)
        (dbi:execute query))))

(defun fetch-all (query)
  "Fetch all rows from an executed query as a list of plists."
  (dbi:fetch-all query))

(defun fetch-one (query)
  "Fetch a single row from an executed query as a plist."
  (dbi:fetch query))

(defun initialize-schema ()
  "Create all database tables if they do not exist."
  (let ((conn (ensure-db)))
    (dolist (ddl (list
                  "CREATE TABLE IF NOT EXISTS users (
                     id TEXT PRIMARY KEY,
                     email TEXT NOT NULL UNIQUE,
                     password_hash TEXT NOT NULL,
                     display_name TEXT,
                     role TEXT NOT NULL DEFAULT 'user',
                     created_at TEXT NOT NULL,
                     updated_at TEXT NOT NULL
                   )"

                  "CREATE TABLE IF NOT EXISTS clients (
                     id TEXT PRIMARY KEY,
                     name TEXT NOT NULL,
                     contact_name TEXT,
                     contact_email TEXT,
                     notes TEXT,
                     created_at TEXT NOT NULL,
                     updated_at TEXT NOT NULL
                   )"

                  "CREATE TABLE IF NOT EXISTS projects (
                     id TEXT PRIMARY KEY,
                     client_id TEXT NOT NULL REFERENCES clients(id),
                     name TEXT NOT NULL,
                     slug TEXT NOT NULL UNIQUE,
                     status TEXT NOT NULL DEFAULT 'active',
                     description TEXT DEFAULT '',
                     created_at TEXT NOT NULL,
                     updated_at TEXT NOT NULL
                   )"

                  "CREATE TABLE IF NOT EXISTS tasks (
                     id TEXT PRIMARY KEY,
                     project_id TEXT NOT NULL REFERENCES projects(id),
                     title TEXT NOT NULL,
                     description TEXT DEFAULT '',
                     status TEXT NOT NULL DEFAULT 'open',
                     priority TEXT NOT NULL DEFAULT 'normal',
                     due_date TEXT,
                     assignee_id TEXT REFERENCES users(id),
                     created_at TEXT NOT NULL,
                     updated_at TEXT NOT NULL
                   )"

                  "CREATE TABLE IF NOT EXISTS project_notes (
                     id TEXT PRIMARY KEY,
                     project_id TEXT NOT NULL REFERENCES projects(id),
                     user_id TEXT NOT NULL REFERENCES users(id),
                     body TEXT NOT NULL,
                     created_at TEXT NOT NULL,
                     updated_at TEXT NOT NULL
                   )"

                  "CREATE TABLE IF NOT EXISTS activity_events (
                     id TEXT PRIMARY KEY,
                     project_id TEXT NOT NULL REFERENCES projects(id),
                     user_id TEXT NOT NULL REFERENCES users(id),
                     event_type TEXT NOT NULL,
                     event_data TEXT,
                     created_at TEXT NOT NULL
                   )"

                  "CREATE TABLE IF NOT EXISTS sessions (
                     id TEXT PRIMARY KEY,
                     user_id TEXT NOT NULL REFERENCES users(id),
                     session_token TEXT NOT NULL UNIQUE,
                     expires_at TEXT NOT NULL,
                     created_at TEXT NOT NULL
                   )"

                  "CREATE TABLE IF NOT EXISTS attachments (
                     id TEXT PRIMARY KEY,
                     project_id TEXT NOT NULL REFERENCES projects(id),
                     filename TEXT NOT NULL,
                     storage_path TEXT NOT NULL,
                     mime_type TEXT,
                     created_at TEXT NOT NULL,
                     updated_at TEXT NOT NULL
                   )"))
      (dbi:do-sql conn ddl)))
  (format t "~&Database schema initialized.~%")
  t)
