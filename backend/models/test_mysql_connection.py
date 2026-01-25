import mysql.connector
from mysql.connector import Error
from backend import config

REQUIRED_TABLES = ['users1', 'emotion_sessions', 'emotion_data']


def main():
    db_cfg = getattr(config, 'DB_CONFIG', None)
    if not db_cfg:
        print('DB_CONFIG not found in backend.config; aborting')
        return 1

    print('Using DB config:', {k: ('***' if k=='password' else v) for k, v in db_cfg.items()})

    try:
        conn = mysql.connector.connect(
            host=db_cfg.get('host'),
            user=db_cfg.get('user'),
            password=db_cfg.get('password'),
            database=db_cfg.get('database'),
            port=int(db_cfg.get('port', 3306))
        )
        if conn.is_connected():
            print('Connected to MySQL server')
            cursor = conn.cursor()
            cursor.execute('SHOW TABLES')
            tables = [row[0] for row in cursor.fetchall()]
            print('Tables in database:', tables)

            missing = [t for t in REQUIRED_TABLES if t not in tables]
            if missing:
                print('Missing tables:', missing)
                print('\nSuggested next steps:')
                print('- Verify the database name in backend/config.py matches your Workbench schema')
                print("- Run the provided CREATE TABLE statements or import SQL to create missing tables")
            else:
                print('All required tables are present')

            cursor.close()
            conn.close()
            return 0
        else:
            print('Failed to connect to database')
            return 2

    except Error as e:
        print('MySQL Error:', e)
        return 3


if __name__ == '__main__':
    raise SystemExit(main())
