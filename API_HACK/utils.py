# utils.py
import os
import mysql.connector
import requests
from dotenv import load_dotenv

load_dotenv()

DB_CONFIG = {
    'host': os.getenv('DB_HOST'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'database': os.getenv('DB_NAME'),
    'port': int(os.getenv('DB_PORT', 26671)),
    'ssl_ca': None,
    'ssl_disabled': False
}

CATEGORIZER_URL = 'http://localhost:3000/categorize'

def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)

def get_transaction_description(tipo_transaccion_id: int) -> str:
    conn = get_db_connection()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT descripcion FROM DimTipoTransaccion WHERE id_tipo_transaccion = %s",
                (tipo_transaccion_id,))
    row = cur.fetchone()
    cur.close(); conn.close()
    return row['descripcion'] if row else "Transacción desconocida"

def categorize_transaction(description: str, amount: float):
    try:
        payload = {'description': description, 'amount': abs(amount)}
        r = requests.post(CATEGORIZER_URL, json=payload, timeout=5)
        if r.status_code == 200:
            data = r.json()
            return data.get('categorization')
        return None
    except Exception:
        return None
