from flask import Flask, jsonify, request
import psycopg2
import os
import subprocess

app = Flask(__name__)

def get_db_connection():
    return psycopg2.connect(
        host=os.getenv('DB_HOST', 'postgres'),
        database=os.getenv('DB_NAME', 'testdb'),
        user=os.getenv('DB_USER', 'user'),
        password=os.getenv('DB_PASSWORD', 'password')
    )

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

@app.route('/users')
def get_users():
    """Normal query - should NOT trigger alert"""
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, username FROM users")
    users = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify(users)

@app.route('/trigger-file-read')
def trigger_file_read():
    """This will trigger the /etc/passwd read alert"""
    try:
        with open('/etc/passwd', 'r') as f:
            content = f.read()
        return jsonify({"status": "read /etc/passwd", "lines": len(content.splitlines())})
    except Exception as e:
        return jsonify({"error": str(e)})

@app.route('/trigger-pii-query')
def trigger_pii_query():
    """This will trigger the SELECT * from PII table alert"""
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT * FROM PII")
    data = cur.fetchall()
    cur.close()
    conn.close()
    return jsonify({"status": "queried PII table", "rows": len(data)})

@app.route('/run-sql', methods=['POST'])
def run_sql():
    """Execute SQL via psql command (detectable by Falco)"""
    query = request.json.get('query', '')
    try:
        cmd = f'PGPASSWORD={os.getenv("DB_PASSWORD")} psql -h {os.getenv("DB_HOST")} -U {os.getenv("DB_USER")} -d {os.getenv("DB_NAME")} -c "{query}"'
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return jsonify({"output": result.stdout, "error": result.stderr})
    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)