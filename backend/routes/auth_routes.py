from flask import Blueprint, request, jsonify
from services.db_service import get_connection
import bcrypt

auth_bp = Blueprint('auth', __name__)


@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')

    if not all([name, email, password]):
        return jsonify({'status': 'error', 'message': 'Missing fields'}), 400

    conn = get_connection()
    if not conn:
        return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

    cursor = conn.cursor(dictionary=True)

    # Check if user already exists
    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
    if cursor.fetchone():
        cursor.close()
        conn.close()
        return jsonify({'status': 'error', 'message': 'User already exists'}), 400

    # Hash password
    hashed_pw = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

    # Insert new user
    cursor.execute(
        "INSERT INTO users (name, email, password_hash) VALUES (%s, %s, %s)",
        (name, email, hashed_pw)
    )
    conn.commit()

    # ✅ Fetch the newly inserted user's ID
    cursor.execute("SELECT user_id, name, email FROM users WHERE email = %s", (email,))
    new_user = cursor.fetchone()

    cursor.close()
    user_id = cursor.lastrowid  # get the ID of the inserted user
    conn.close()

    return jsonify({
         'status': 'success',
         'message': 'User registered successfully',
         'user_id': user_id
        }), 201



@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    if not all([email, password]):
        return jsonify({'status': 'error', 'message': 'Missing fields'}), 400

    conn = get_connection()
    if not conn:
        return jsonify({'status': 'error', 'message': 'Database connection failed'}), 500

    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT user_id, name, email, password_hash FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()

    if not user:
        return jsonify({'status': 'error', 'message': 'User not found'}), 404

    # Validate password
    if not bcrypt.checkpw(password.encode('utf-8'), user['password_hash'].encode('utf-8')):
        return jsonify({'status': 'error', 'message': 'Invalid password'}), 401

    # ✅ Return user details (including id)
    return jsonify({
        'status': 'success',
        'message': 'Login successful',
        'user_id': user['user_id']
    }), 200
