# Workbench

A lightweight internal operations system for freelancers and small teams, built in Common Lisp.

## Overview

Workbench is a browser-based application for managing clients, projects, tasks, notes, and activity in one minimal web interface. It is designed to be fast, self-hostable, and easy to maintain.

## Technical Stack

- **Language:** Common Lisp
- **Architecture:** CLOS-based domain model with layered architecture
- **Database:** SQLite (via cl-dbi + dbd-sqlite3)
- **Web Server:** Hunchentoot
- **HTML:** CL-WHO
- **CSS:** LASS (Lisp-derived stylesheets)
- **JavaScript:** Parenscript (Lisp-to-JS compiler)
- **Crypto:** Ironclad
- **Threading:** Bordeaux-Threads

## Project Structure

```text
workbench/
├── workbench.asd          # ASDF system definition
├── src/
│   ├── packages.lisp      # Package definition
│   ├── config.lisp        # Application configuration
│   ├── core.lisp          # Application entry point
│   ├── domain/            # CLOS classes and business logic
│   ├── repository/        # Database access layer
│   ├── service/           # Use-case workflows
│   ├── web/               # Routes, views, and templates
│   └── util/              # Utilities (time, IDs, crypto)
├── static/
│   ├── css/
│   └── js/
└── data/                  # SQLite database location
```

## Getting Started

### Prerequisites

- [SBCL](http://www.sbcl.org/) (or another Common Lisp implementation)
- [Quicklisp](https://www.quicklisp.org/)

### Loading and Running

```lisp
;; From your REPL, with Quicklisp available:
(push #p"/path/to/workbench/" asdf:*central-registry*)
(ql:quickload "workbench")

;; Start the application (port 8089)
(workbench:start-workbench)

;; Seed demo data (creates admin user + sample clients/projects/tasks)
(workbench:seed-demo-data)

;; Visit http://localhost:8089/
;; Login: admin@workbench.local / admin

;; To stop:
(workbench:stop-workbench)
```

## Features (v1)

- User authentication (login/logout)
- Dashboard with project and task summaries
- Client management (CRUD)
- Project management (CRUD, status changes)
- Project notes (append-only)
- Task tracking (create, complete, reopen)
- Activity timeline

## License

MIT
