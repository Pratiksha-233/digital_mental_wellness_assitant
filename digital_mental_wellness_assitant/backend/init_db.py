import os
from pathlib import Path
import sys
try:
    import mysql.connector as mysql_connector  # type: ignore
    from mysql.connector import Error  # type: ignore
except Exception:  # pragma: no cover
    mysql_connector = None
    Error = Exception

from services.sqlite_db import connect_sqlite


sys.path.insert(0, str(Path(__file__).resolve().parent))


try:
    import config
except ImportError:
    try:
        from . import config
    except ImportError:
        print("Error: Could not import config module")
        sys.exit(1)


def read_sql_file(p: Path) -> str:
    with open(p, 'r', encoding='utf-8') as f:
        return f.read()


def execute_sql_file(conn, sql_text: str):
    """Execute SQL statements from a SQL script.

    Supports MySQL `DELIMITER` blocks (needed for stored procedures).
    """
    cursor = conn.cursor()
    try:
        statements: list[str] = []
        current: list[str] = []
        delimiter = ";"

        for raw_line in sql_text.splitlines():
            line = raw_line.rstrip("\n")
            stripped = line.strip()

            if not stripped:
                continue

            # Skip full-line comments.
            if stripped.startswith("--"):
                continue

            # Handle MySQL delimiter changes (used for procedures/triggers).
            if stripped.upper().startswith("DELIMITER "):
                parts = stripped.split(None, 1)
                if len(parts) == 2 and parts[1].strip():
                    delimiter = parts[1].strip()
                continue

            # Strip inline comments (basic).
            if "--" in line:
                idx = line.find("--")
                before = line[:idx]
                if before.strip():
                    line = before.rstrip()
                    stripped = line.strip()
                else:
                    continue

            current.append(line)

            is_end = False
            if delimiter == ";":
                is_end = stripped.endswith(";")
            else:
                is_end = stripped.endswith(delimiter)

            if is_end:
                stmt = "\n".join(current).rstrip()
                if delimiter != ";" and stmt.endswith(delimiter):
                    stmt = stmt[: -len(delimiter)]
                elif delimiter == ";" and stmt.endswith(";"):
                    stmt = stmt[:-1]

                stmt = stmt.strip()
                if stmt:
                    statements.append(stmt)
                current = []

        # Flush remaining buffered SQL if any.
        tail = "\n".join(current).strip()
        if tail:
            statements.append(tail)

        executed = 0
        for stmt in statements:
            try:
                cursor.execute(stmt)
                if getattr(cursor, "with_rows", False):
                    cursor.fetchall()
                executed += 1
            except Error as e:
                print(f"Warning executing statement: {e}")

        conn.commit()
        print(f"✅ Executed {executed}/{len(statements)} statements")
    except Error as e:
        print(f"❌ Database error: {e}")
        conn.rollback()
    finally:
        cursor.close()


def main():
    root = Path(__file__).resolve().parent.parent
    db_dir = root / 'frontend' / 'database'
    files = [db_dir / 'mental_wellness.sql', db_dir / 'sample_data.sql']

    missing = [str(p) for p in files if not p.exists()]
    if missing:
        print("Missing SQL files:", missing)
        return 1

    engine = getattr(config, 'DB_ENGINE', 'mysql')
    if str(engine).lower() == 'sqlite':
        try:
            conn = connect_sqlite(getattr(config, 'SQLITE_PATH', 'mental_wellness.sqlite3'))
            conn.close()
            print("✅ SQLite database initialized:", getattr(config, 'SQLITE_PATH', 'mental_wellness.sqlite3'))
            return 0
        except Exception as e:
            print('Failed to initialize SQLite:', e)
            return 2

    try:
        if mysql_connector is None:
            raise ImportError('mysql-connector-python is not installed')

        conn = mysql_connector.connect(
            host=config.DB_CONFIG.get('host', 'localhost'),
            user=config.DB_CONFIG.get('user', 'root'),
            password=config.DB_CONFIG.get('password', 'mysqlworld@123'),     
            database=os.getenv('DB_NAME', 'mental_wellness'),
            port=config.DB_CONFIG.get('port', 3306),
            charset=config.DB_CONFIG.get('charset', 'utf8mb4')
        )
    except Error as e:
        print('Failed to connect to MySQL:', e)
        return 2

    try:
        for p in files:
            print(f"Executing: {p}")
            sql_text = read_sql_file(p)
            execute_sql_file(conn, sql_text)
            print(f"Executed: {p}")
        print("✅ Database initialization completed.")
        return 0
    except Error as e:
        print('SQL execution error:', e)
        return 3
    finally:
        conn.close()


if __name__ == '__main__':
    raise SystemExit(main())
