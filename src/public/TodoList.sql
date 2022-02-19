CREATE TABLE IF NOT EXISTS TodoList (
    Id          INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Project     TEXT NOT NULL,
    Description TEXT NOT NULL,
    Priority    TEXT NOT NULL,
    Status      TEXT NOT NULL,
    StartDate   DATETIME NOT NULL,
    DueDate     DATETIME NOT NULL
);
