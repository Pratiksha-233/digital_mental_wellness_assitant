from __future__ import annotations

import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Optional, Sequence


SCHEMA_STATEMENTS: list[str] = [
    """
    CREATE TABLE IF NOT EXISTS users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        password_hash TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
    """.strip(),
    """
    CREATE TABLE IF NOT EXISTS journal_entries (
        entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        text_entry TEXT NOT NULL,
        predicted_emotion TEXT,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    )
    """.strip(),
    """
    CREATE TABLE IF NOT EXISTS mood_logs (
        log_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        mood_label TEXT NOT NULL,
        energy_level INTEGER,
        activities TEXT,
        note TEXT,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    )
    """.strip(),
    """
    CREATE TABLE IF NOT EXISTS chat_history (
        chat_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        user_message TEXT,
        bot_response TEXT,
        emotion_detected TEXT,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    )
    """.strip(),
    """
    CREATE TABLE IF NOT EXISTS recommendations (
        rec_id INTEGER PRIMARY KEY AUTOINCREMENT,
        emotion_type TEXT,
        suggestion_text TEXT,
        resource_link TEXT
    )
    """.strip(),
    """
    CREATE TABLE IF NOT EXISTS activity_logs (
        activity_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        activity_type TEXT,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    )
    """.strip(),
    """
    CREATE TABLE IF NOT EXISTS stress_logs (
        stress_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        stress_level REAL,
        stress_category TEXT,
        primary_emotion TEXT,
        energy_level INTEGER,
        mood_pattern TEXT,
        activity_frequency INTEGER,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    )
    """.strip(),
    """
    CREATE INDEX IF NOT EXISTS idx_stress_user_id ON stress_logs(user_id)
    """.strip(),
    """
    CREATE INDEX IF NOT EXISTS idx_stress_timestamp ON stress_logs(timestamp)
    """.strip(),
    """
    CREATE TABLE IF NOT EXISTS face_detection_logs (
        detection_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        detected_emotion TEXT,
        confidence_score REAL,
        faces_detected INTEGER,
        detection_method TEXT,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    )
    """.strip(),
]


def _translate_params(sql: str) -> str:
    # mysql.connector uses %s placeholders; sqlite3 uses ?
    return sql.replace("%s", "?")


class SQLiteCompatCursor:
    def __init__(self, cursor: sqlite3.Cursor, *, dictionary: bool):
        self._cursor = cursor
        self._dictionary = dictionary
        self.with_rows = False

    @property
    def lastrowid(self) -> int:
        return int(self._cursor.lastrowid or 0)

    def execute(self, sql: str, params: Optional[Sequence[Any]] = None):
        sql2 = _translate_params(sql)
        if params is None:
            self._cursor.execute(sql2)
        else:
            self._cursor.execute(sql2, params)
        self.with_rows = self._cursor.description is not None
        return self

    def executemany(self, sql: str, seq_of_params: Iterable[Sequence[Any]]):
        sql2 = _translate_params(sql)
        self._cursor.executemany(sql2, seq_of_params)
        self.with_rows = self._cursor.description is not None
        return self

    def fetchone(self):
        row = self._cursor.fetchone()
        if row is None:
            return None
        if self._dictionary:
            return dict(row)
        return row

    def fetchall(self):
        rows = self._cursor.fetchall() or []
        if self._dictionary:
            return [dict(r) for r in rows]
        return rows

    def close(self):
        try:
            self._cursor.close()
        except Exception:
            pass


class SQLiteCompatConnection:
    """A small wrapper that mimics mysql.connector's connection surface."""

    def __init__(self, conn: sqlite3.Connection):
        self._conn = conn
        self.autocommit = False
        self.engine = "sqlite"

    def is_connected(self) -> bool:
        return True

    def cursor(self, dictionary: bool = False):
        return SQLiteCompatCursor(self._conn.cursor(), dictionary=dictionary)

    def commit(self):
        return self._conn.commit()

    def rollback(self):
        return self._conn.rollback()

    def close(self):
        return self._conn.close()


def ensure_schema(conn: SQLiteCompatConnection) -> None:
    cur = conn.cursor()
    try:
        for stmt in SCHEMA_STATEMENTS:
            cur.execute(stmt)
        conn.commit()
    finally:
        cur.close()


def connect_sqlite(db_path: str | Path) -> SQLiteCompatConnection:
    p = Path(db_path)
    p.parent.mkdir(parents=True, exist_ok=True)

    raw = sqlite3.connect(str(p), check_same_thread=False)
    raw.row_factory = sqlite3.Row

    conn = SQLiteCompatConnection(raw)

    cur = conn.cursor()
    try:
        cur.execute("PRAGMA foreign_keys = ON")
        cur.execute("PRAGMA journal_mode = WAL")
    finally:
        cur.close()

    ensure_schema(conn)
    return conn
