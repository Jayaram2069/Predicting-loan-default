from flask import Flask, jsonify, request
import sqlite3

app = Flask(__name__)

def get_db_connection():
    conn = sqlite3.connect('airline_system.db')
    conn.row_factory = sqlite3.Row
    return conn

@app.route('/flights', methods=['GET'])
def get_flights():
    conn = get_db_connection()
    flights = conn.execute('SELECT * FROM flights').fetchall()
    conn.close()
    return jsonify([dict(f) for f in flights])

@app.route('/book', methods=['POST'])
def book_ticket():
    data = request.json
    conn = get_db_connection()
    conn.execute('INSERT INTO tickets (flight_id, passenger_id, seat_number) VALUES (?, ?, ?)',
                 (data['flight_id'], data['passenger_id'], data['seat_number']))
    conn.commit()
    conn.close()
    return jsonify({'status': 'Booking successful'})

if __name__ == '__main__':
    app.run(debug=True)
