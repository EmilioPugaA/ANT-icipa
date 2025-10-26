import mysql.connector
import os
from dotenv import load_dotenv

load_dotenv()

try:
    conn = mysql.connector.connect(
        host=os.getenv('DB_HOST'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        database=os.getenv('DB_NAME'),
        port=int(os.getenv('DB_PORT', 20958)),
        ssl_disabled=False,
        ssl_verify_cert=False,
        ssl_verify_identity=False
    )
    print("✅ Conexión exitosa a Aiven MySQL!")
    
    cursor = conn.cursor()
    cursor.execute("SHOW TABLES;")
    tables = cursor.fetchall()
    
    print(f"\n📊 Tablas encontradas ({len(tables)}):")
    for table in tables:
        print(f"  - {table[0]}")
    
    conn.close()
    
except mysql.connector.Error as err:
    print(f"❌ Error de conexión: {err}")
    print(f"\nDetalles:")
    print(f"  Host: {os.getenv('DB_HOST')}")
    print(f"  User: {os.getenv('DB_USER')}")
    print(f"  Database: {os.getenv('DB_NAME')}")
    print(f"  Port: {os.getenv('DB_PORT', '26671')}")
