# app.py
from flask import Flask
from flask_cors import CORS
from flasgger import Swagger

app = Flask(__name__)
CORS(app)

swagger = Swagger(app, template={
    "swagger": "2.0",
    "info": {
        "title": "ANTicipa API",
        "description": "API para categorización automática de transacciones y autenticación",
        "version": "1.0.0"
    }
})

# Registrar blueprint (después de crear app)
from routes import api_bp
app.register_blueprint(api_bp)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
