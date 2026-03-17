import os
from pathlib import Path
import sys
import mysql.connector
from mysql.connector import Error

# Ensure backend directory is on sys.path
sys.path.insert(0, str(Path(__file__).resolve().parent))

# Import config robustly
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


def execute_sql_file(conn: mysql.connector.MySQLConnection, sql_text: str):
    """Execute SQL statements from a text string, splitting by ; and --"""
    cursor = conn.cursor()
    try:
        # Split SQL into individual statements, removing comments and empty lines
        statements = []
        current_stmt = []
        
        for line in sql_text.split('\n'):
            # Remove comments
            if '--' in line:
                line = line[:line.index('--')]
            line = line.strip()
            
            if line:
                current_stmt.append(line)
                
                # Check if statement ends with semicolon
                if line.endswith(';'):
                    stmt = ' '.join(current_stmt).replace(';', '')
                    if stmt.strip():
                        statements.append(stmt)
                    current_stmt = []
        
        # Execute each statement
        for stmt in statements:
            if stmt.strip():
                try:
                    cursor.execute(stmt)
                    if cursor.with_rows:
                        cursor.fetchall()
                except Error as e:
                    print(f"Warning executing statement: {e}")
                    # Continue even if individual statements fail
        
        conn.commit()
        print(f"✅ Successfully executed {len(statements)} statements")
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

    try:
        conn = mysql.connector.connect(
            host=config.DB_CONFIG.get('host', 'localhost'),
            user=config.DB_CONFIG.get('user', 'root'),
            password=config.DB_CONFIG.get('password', 'nayan@337'),
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
