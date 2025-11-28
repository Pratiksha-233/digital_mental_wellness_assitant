# Backend (Flask) - quick start
1. Create a virtualenv and install requirements:
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt


2. Create `.env` with DB credentials:
DB_HOST=localhost
DB_USER=root
DB_PASS=yourpass
DB_NAME=mental_wellness
SECRET_KEY=replace-me


3. Import `database/mental_wellness.sql` into MySQL.
4. Run backend:
python app.py