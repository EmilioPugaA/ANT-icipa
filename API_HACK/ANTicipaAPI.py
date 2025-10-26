import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # Credenciales de tu Aiven MySQL
    DB_HOST = os.getenv('DB_HOST', 'mysql-bc8b53c-tec-85e0.f.aivencloud.com')
    DB_PORT = int(os.getenv('DB_PORT', 20958))
    DB_USER = os.getenv('DB_USER', 'avnadmin')
    DB_PASSWORD = os.getenv('DB_PASSWORD', 'AVNS_yJFPmpUVlmUynfXkr6d')
    DB_NAME = os.getenv('DB_NAME', 'defaultdb')
    
    @staticmethod
    def get_db_config():
        return {
            'host': Config.DB_HOST,
            'port': Config.DB_PORT,
            'user': Config.DB_USER,
            'password': Config.DB_PASSWORD,
            'database': Config.DB_NAME,
            'ssl_disabled': False  # Cambio aquí - desactiva verificación SSL
        }
