from flask import Blueprint, jsonify, request
from datetime import datetime
import requests


from utils import (
    get_db_connection,
    get_transaction_description,
    categorize_transaction
)


api_bp = Blueprint('api', __name__)


@api_bp.route('/', methods=['GET'])
def root():
    """
    Bienvenida a la API
    ---
    tags:
      - General
    responses:
      200:
        description: Información de la API
        schema:
          type: object
    """
    return jsonify({
        'message': 'ANTicipa API - Categorización Automática de Transacciones',
        'version': '1.0.0',
        'status': 'online',
        'endpoints': {
            'health': '/api/health',
            'add_transaction': 'POST /api/transactions',
            'get_transactions': 'GET /api/transactions/{cliente_id}',
            'gastos_hormiga': 'GET /api/transactions/gastos-hormiga/{cliente_id}',
            'stats': 'GET /api/transactions/stats/{cliente_id}',
            'feedback': 'POST /api/feedback',
            'login': 'POST /api/auth/login'
        },
        'documentation': 'Usa /api/health para verificar el estado del sistema'
    }), 200


@api_bp.route('/api/health', methods=['GET'])
def health_check():
    """
    Estado del sistema
    ---
    tags:
      - Health
    responses:
      200:
        description: Estado de todos los servicios
        schema:
          type: object
    """
    try:
        conn = get_db_connection(); conn.close()
        db_status = 'ok'
    except:
        db_status = 'error'


    try:
        r = requests.get('http://localhost:3000/health', timeout=2)
        categorizer_status = 'ok' if r.status_code == 200 else 'error'
    except:
        categorizer_status = 'offline'


    return jsonify({
        'api': 'ok',
        'database': db_status,
        'categorizer': categorizer_status,
        'timestamp': datetime.now().isoformat()
    }), 200


@api_bp.route('/api/auth/login', methods=['POST'])
def login():
    """
    Inicio de sesión
    ---
    tags:
      - Autenticación
    consumes:
      - application/json
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - email
            - password
          properties:
            email:
              type: string
              example: "juan@example.com"
            password:
              type: string
              example: "password123"
    responses:
      200:
        description: Login exitoso
      401:
        description: Credenciales inválidas
    """
    try:
        data = request.json or {}
        email = data.get('email')
        password = data.get('password')
        if not email or not password:
            return jsonify({'success': False, 'message': 'Email y contraseña son requeridos'}), 400


        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT id_cliente, numero_cliente, nombre_completo, email, contrasena,
                   segmento_cliente, estado_cliente, fecha_ingreso_banco, balance
            FROM DimCliente
            WHERE email = %s AND estado_cliente = 'Activo'
        """, (email,))
        user = cur.fetchone()
        cur.close()
        conn.close()


        if not user or user['contrasena'] != password:
            return jsonify({'success': False, 'message': 'Credenciales inválidas o cuenta inactiva'}), 401


        return jsonify({
            'success': True,
            'message': 'Inicio de sesión exitoso',
            'user': {
                'id_cliente': user['id_cliente'],
                'numero_cliente': user['numero_cliente'],
                'nombre_completo': user['nombre_completo'],
                'email': user['email'],
                'segmento_cliente': user['segmento_cliente'],
                'fecha_ingreso_banco': user['fecha_ingreso_banco'].strftime('%Y-%m-%d') if user['fecha_ingreso_banco'] else None,
                'balance': float(user['balance']) if user.get('balance') is not None else 0
            }
        }), 200
    except Exception as e:
        return jsonify({'success': False, 'message': 'Error interno del servidor'}), 500



@api_bp.route('/api/transactions', methods=['POST'])
def add_transaction():
    try:
        data = request.json or {}
        required = ['id_cliente', 'id_cuenta', 'id_fecha', 'id_tipo_transaccion', 'monto']
        for f in required:
            if f not in data:
                return jsonify({'error': f'Campo requerido: {f}'}), 400

        id_cliente = data['id_cliente']
        id_cuenta = data['id_cuenta']
        id_fecha = data['id_fecha']
        id_tipo_transaccion = data['id_tipo_transaccion']
        monto = data['monto']
        es_credito = data.get('es_credito', 0)

        descripcion = data.get('descripcion_comercio') or get_transaction_description(id_tipo_transaccion)
        categorization = categorize_transaction(descripcion, abs(monto))

        category = confidence = reasoning = None
        is_gasto_hormiga = auto_categorized = 0
        suggestions = []

        if categorization:
            category = categorization.get('category')
            confidence = categorization.get('confidence')
            is_gasto_hormiga = 1 if categorization.get('isGastoHormiga', False) else 0
            reasoning = categorization.get('reasoning')
            suggestions = categorization.get('suggestions', [])
            auto_categorized = 1

        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)

        cur.execute("SELECT balance FROM DimCliente WHERE id_cliente = %s", (id_cliente,))
        row = cur.fetchone()
        if not row:
            cur.close()
            conn.close()
            return jsonify({'error': 'Cliente no encontrado'}), 404

        balance_actual = float(row['balance'])
        balance_resultante = balance_actual + monto

        if balance_resultante < 0:
            cur.close()
            conn.close()
            return jsonify({'error': 'Fondos insuficientes'}), 400

        cur.execute("""
            INSERT INTO FactTransacciones 
            (id_cliente, id_cuenta, id_fecha, id_tipo_transaccion, monto, 
             balance_resultante, es_credito, category, category_confidence, 
             is_gasto_hormiga, categorization_reasoning, auto_categorized)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (id_cliente, id_cuenta, id_fecha, id_tipo_transaccion, monto,
              balance_resultante, es_credito, category, confidence,
              is_gasto_hormiga, reasoning, auto_categorized))
        transaction_id = cur.lastrowid

        # Duplica si es gasto hormiga
        if is_gasto_hormiga:
            cur.execute("""
                INSERT INTO TransaccionesDuplicadas
                (id_cliente, id_cuenta, id_fecha, id_tipo_transaccion, monto,
                 category, confidence, reasoning, original_transaction_id)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """, (id_cliente, id_cuenta, id_fecha, id_tipo_transaccion, monto,
                  category, confidence, reasoning, transaction_id))

        cur.execute("UPDATE DimCliente SET balance = %s WHERE id_cliente = %s", (balance_resultante, id_cliente))

        if suggestions:
            for s in suggestions:
                cur.execute("INSERT INTO categorization_suggestions (transaction_id, suggestion) VALUES (%s,%s)",
                            (transaction_id, s))

        if category and auto_categorized:
            cur.execute("""
                INSERT INTO merchant_patterns (merchant_name, category, cliente_id, times_seen, avg_confidence)
                VALUES (%s,%s,%s,1,%s)
                ON DUPLICATE KEY UPDATE 
                    times_seen = times_seen + 1,
                    avg_confidence = (avg_confidence * times_seen + %s) / (times_seen + 1)
            """, (descripcion, category, id_cliente, confidence, confidence))

        conn.commit()
        cur.close()
        conn.close()

        return jsonify({
            'success': True,
            'transaction_id': transaction_id,
            'transaction': {
                'id': transaction_id,
                'descripcion': descripcion,
                'monto': monto,
                'category': category,
                'confidence': confidence,
                'is_gasto_hormiga': is_gasto_hormiga,
                'auto_categorized': auto_categorized,
                'balance_resultante': balance_resultante
            },
            'categorization': categorization,
            'suggestions': suggestions
        }), 201

    except Exception as e:
        return jsonify({'error': str(e)}), 500


# Resto de tus endpoints (get_transactions, get_gastos_hormiga, etc.) mantienen el mismo código...

@api_bp.route('/api/transactions/<int:cliente_id>', methods=['GET'])
def get_transactions(cliente_id):
    """
    Obtener transacciones de un cliente
    ---
    tags:
      - Transacciones
    parameters:
      - name: cliente_id
        in: path
        type: integer
        required: true
        description: ID del cliente
        example: 1
    responses:
      200:
        description: Lista de transacciones
        schema:
          type: object
    """
    try:
        conn = get_db_connection(); cur = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT 
                ft.*,
                dtt.descripcion as tipo_descripcion,
                dtt.categoria as tipo_categoria,
                GROUP_CONCAT(cs.suggestion SEPARATOR '|||') as suggestions
            FROM FactTransacciones ft
            LEFT JOIN DimTipoTransaccion dtt ON ft.id_tipo_transaccion = dtt.id_tipo_transaccion
            LEFT JOIN categorization_suggestions cs ON ft.id_transaccion = cs.transaction_id
            WHERE ft.id_cliente = %s
            GROUP BY ft.id_transaccion
            ORDER BY ft.id_fecha DESC, ft.fecha_hora_transaccion DESC
        """, (cliente_id,))
        rows = cur.fetchall()
        cur.close(); conn.close()

        for r in rows:
            r['suggestions'] = r['suggestions'].split('|||') if r['suggestions'] else []

        return jsonify({'success': True, 'count': len(rows), 'transactions': rows}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api_bp.route('/api/transactions/gastos-hormiga/<int:cliente_id>', methods=['GET'])
def get_gastos_hormiga(cliente_id):
    """
    Obtener gastos hormiga de un cliente
    ---
    tags:
      - Transacciones
    parameters:
      - name: cliente_id
        in: path
        type: integer
        required: true
        description: ID del cliente
        example: 1
    responses:
      200:
        description: Lista de gastos hormiga
        schema:
          type: object
    """
    try:
        conn = get_db_connection(); cur = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT ft.*, dtt.descripcion as tipo_descripcion
            FROM FactTransacciones ft
            LEFT JOIN DimTipoTransaccion dtt ON ft.id_tipo_transaccion = dtt.id_tipo_transaccion
            WHERE ft.id_cliente = %s AND ft.is_gasto_hormiga = 1
            ORDER BY ft.id_fecha DESC
        """, (cliente_id,))
        rows = cur.fetchall()
        cur.close(); conn.close()

        total = sum(float(r['monto']) for r in rows if r['es_credito'] == 0)
        return jsonify({'success': True, 'count': len(rows), 'total': total, 'gastos_hormiga': rows}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api_bp.route('/api/transactions/stats/<int:cliente_id>', methods=['GET'])
def get_transaction_stats(cliente_id):
    """
    Obtener estadísticas por categoría
    ---
    tags:
      - Transacciones
    parameters:
      - name: cliente_id
        in: path
        type: integer
        required: true
        description: ID del cliente
        example: 1
    responses:
      200:
        description: Estadísticas por categoría
        schema:
          type: object
    """
    try:
        conn = get_db_connection(); cur = conn.cursor(dictionary=True)
        cur.execute("""
            SELECT 
                category,
                COUNT(*) as count,
                SUM(CASE WHEN es_credito = 0 THEN monto ELSE 0 END) as total_debitos,
                SUM(CASE WHEN es_credito = 1 THEN monto ELSE 0 END) as total_creditos,
                AVG(monto) as average,
                SUM(CASE WHEN is_gasto_hormiga = 1 THEN 1 ELSE 0 END) as gastos_hormiga_count
            FROM FactTransacciones
            WHERE id_cliente = %s AND category IS NOT NULL
            GROUP BY category
            ORDER BY total_debitos DESC
        """, (cliente_id,))
        stats = cur.fetchall()
        cur.close(); conn.close()

        return jsonify({'success': True, 'stats': stats}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api_bp.route('/api/transactions/all', methods=['GET'])
def get_all_transactions():
    """
    Obtener todas las transacciones de la base
    ---
    tags:
      - Transacciones
    responses:
      200:
        description: Lista completa de transacciones
        schema:
          type: object
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT 
                ft.*,
                dtt.descripcion AS tipo_descripcion,
                dtt.categoria  AS tipo_categoria,
                GROUP_CONCAT(cs.suggestion SEPARATOR '|||') AS suggestions
            FROM FactTransacciones ft
            LEFT JOIN DimTipoTransaccion dtt ON ft.id_tipo_transaccion = dtt.id_tipo_transaccion
            LEFT JOIN categorization_suggestions cs ON ft.id_transaccion = cs.transaction_id
            GROUP BY ft.id_transaccion
            ORDER BY ft.id_fecha DESC, ft.fecha_hora_transaccion DESC
        """
        cursor.execute(query)
        rows = cursor.fetchall()
        for r in rows:
            r['suggestions'] = r['suggestions'].split('|||') if r['suggestions'] else []
        cursor.close(); conn.close()
        return jsonify({'success': True, 'count': len(rows), 'transactions': rows}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api_bp.route('/api/webhooks/transfer-received', methods=['POST'])
def transfer_received_webhook():
    """
    Webhook: alerta de transferencia recibida
    ---
    tags:
      - Webhooks
    consumes:
      - application/json
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - id_cliente
            - id_cuenta
            - monto
            - referencia
          properties:
            id_cliente:
              type: integer
            id_cuenta:
              type: integer
            monto:
              type: number
            referencia:
              type: string
            id_fecha:
              type: integer
    responses:
      200:
        description: Transferencia recibida registrada
    """
    try:
        data = request.json or {}
        required = ['id_cliente', 'id_cuenta', 'monto', 'referencia']
        for f in required:
            if f not in data:
                return jsonify({'error': f'Campo requerido: {f}'}), 400

        id_cliente = data['id_cliente']
        id_cuenta  = data['id_cuenta']
        monto      = float(data['monto'])
        referencia = data['referencia']
        id_fecha   = int(data.get('id_fecha', datetime.now().strftime('%Y%m%d')))

        id_tipo_transaccion = data.get('id_tipo_transaccion', 5)
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO FactTransacciones
            (id_cliente, id_cuenta, id_fecha, id_tipo_transaccion, monto,
             balance_resultante, es_credito, category, category_confidence,
             is_gasto_hormiga, categorization_reasoning, auto_categorized, referencia_webhook)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,1,%s)
        """, (
            id_cliente, id_cuenta, id_fecha, id_tipo_transaccion, monto,
            0, 1,
            'Transferencia Entrante', 1.0, 0, 'Webhook transferencia entrante', referencia
        ))
        trx_id = cur.lastrowid
        conn.commit()
        cur.close(); conn.close()
        return jsonify({
            'success': True,
            'message': 'Transferencia recibida registrada',
            'transaction_id': trx_id
        }), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@api_bp.route('/api/transfer/simulate', methods=['POST'])
def simulate_transfer():
    """
    Simular transferencia entre cuentas (débito y crédito atómicos)
    ---
    tags:
      - Transferencias
    consumes:
      - application/json
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - cliente_origen
            - cuenta_origen
            - cliente_destino
            - cuenta_destino
            - monto
          properties:
            cliente_origen:
              type: integer
            cuenta_origen:
              type: integer
            cliente_destino:
              type: integer
            cuenta_destino:
              type: integer
            monto:
              type: number
            referencia:
              type: string
            id_fecha:
              type: integer
    responses:
      200:
        description: Transferencia realizada
      400:
        description: Error de validación
      500:
        description: Error interno
    """
    try:
        data = request.json or {}
        required = ['cliente_origen', 'cuenta_origen', 'cliente_destino', 'cuenta_destino', 'monto']
        for f in required:
            if f not in data:
                return jsonify({'error': f'Campo requerido: {f}'}), 400

        c_orig  = int(data['cliente_origen'])
        a_orig  = int(data['cuenta_origen'])
        c_dest  = int(data['cliente_destino'])
        a_dest  = int(data['cuenta_destino'])
        monto   = float(data['monto'])
        ref     = data.get('referencia', f'SIM-{datetime.now().strftime("%Y%m%d%H%M%S")}')
        id_fecha = int(data.get('id_fecha', datetime.now().strftime('%Y%m%d')))
        id_tt_transfer = int(data.get('id_tipo_transaccion', 5))

        if monto <= 0:
            return jsonify({'error': 'El monto debe ser mayor a 0'}), 400

        conn = get_db_connection()
        conn.start_transaction()
        cur = conn.cursor()

        # Débito en origen (es_credito = 0)
        cur.execute("""
            INSERT INTO FactTransacciones
            (id_cliente, id_cuenta, id_fecha, id_tipo_transaccion, monto,
             balance_resultante, es_credito, category, category_confidence,
             is_gasto_hormiga, categorization_reasoning, auto_categorized, referencia_webhook)
            VALUES (%s,%s,%s,%s,%s,%s,0,%s,%s,%s,%s,1,%s)
        """, (
            c_orig, a_orig, id_fecha, id_tt_transfer, -abs(monto),
            0, 'Transferencia Saliente', 1.0, 0, 'Simulación de transferencia (débito)', ref
        ))
        trx_debito = cur.lastrowid

        # Crédito en destino (es_credito = 1)
        cur.execute("""
            INSERT INTO FactTransacciones
            (id_cliente, id_cuenta, id_fecha, id_tipo_transaccion, monto,
             balance_resultante, es_credito, category, category_confidence,
             is_gasto_hormiga, categorization_reasoning, auto_categorized, referencia_webhook)
            VALUES (%s,%s,%s,%s,%s,%s,1,%s,%s,%s,%s,1,%s)
        """, (
            c_dest, a_dest, id_fecha, id_tt_transfer, abs(monto),
            0, 'Transferencia Entrante', 1.0, 0, 'Simulación de transferencia (crédito)', ref
        ))
        trx_credito = cur.lastrowid

        conn.commit()
        cur.close(); conn.close()

        return jsonify({
            'success': True,
            'message': 'Transferencia simulada correctamente',
            'reference': ref,
            'debit_transaction_id': trx_debito,
            'credit_transaction_id': trx_credito
        }), 200

    except Exception as e:
        try:
            conn.rollback()
        except:
            pass
        return jsonify({'error': str(e)}), 500
    
@api_bp.route('/api/duplicated-transactions', methods=['GET'])
def get_duplicated_transactions():
    """
    Obtener todas las transacciones duplicadas (gastos hormiga)
    ---
    tags:
      - Transacciones
    responses:
      200:
        description: Lista completa de duplicados
        schema:
          type: object
    """
    try:
        conn = get_db_connection()
        cur = conn.cursor(dictionary=True)
        cur.execute("SELECT * FROM TransaccionesDuplicadas ORDER BY id DESC")
        rows = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify({'success': True, 'count': len(rows), 'duplicated_transactions': rows}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

from flask import jsonify, request
from flasgger import swag_from

@api_bp.route('/api/estadisticas_gastohormiga', methods=['GET'])
@swag_from({
    'parameters': [
        {
            'name': 'id_usuario',
            'in': 'query',
            'type': 'integer',
            'required': True,
            'description': 'ID del usuario para consultar estadísticas mensuales'
        },
    ],
    'responses': {
        200: {
            'description': 'Lista de estadísticas por mes',
            'content': {
                'application/json': {
                    'schema': {
                        'type': 'array',
                        'items': {
                            'type': 'object',
                            'properties': {
                                'mes': {'type': 'string'},
                                'gasto_mes': {'type': 'number'},
                                'ahorro_mes': {'type': 'number'},
                                'inversion_acumulada': {'type': 'number'}
                            }
                        }
                    }
                }
            }
        },
        400: {
            'description': 'Error, falta parámetro id_usuario'
        }
    }
})
def estadisticas_gastohormiga():
    id_usuario = request.args.get('id_usuario', type=int)
    if not id_usuario:
        return jsonify({"error": "Falta el parámetro id_usuario"}), 400

    query = """
    SELECT
      df.nombre_mes AS mes,
      COALESCE(SUM(CASE WHEN ft.is_gasto_hormiga = 1 THEN ABS(ft.monto) ELSE 0 END), 0) AS gasto_mes,
      COALESCE(SUM(CASE WHEN LOWER(TRIM(ft.category)) = 'ahorro hormiga' THEN ft.monto ELSE 0 END), 0) AS ahorro_mes,
      ROUND(
        SUM(SUM(CASE WHEN LOWER(TRIM(ft.category)) = 'ahorro hormiga' THEN ft.monto ELSE 0 END))
        OVER (ORDER BY df.mes ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        * POWER(1.07, df.mes),
        2
      ) AS inversion_acumulada
    FROM FactTransacciones ft
    JOIN DimFecha df ON ft.id_fecha = df.id_fecha
    WHERE ft.id_cliente = %s
      AND (ft.is_gasto_hormiga = 1 OR LOWER(TRIM(ft.category)) = 'ahorro hormiga')
    GROUP BY df.nombre_mes, df.mes
    ORDER BY df.mes;
    """

    conn = get_db_connection()
    cur = conn.cursor(dictionary=True)
    cur.execute(query, (id_usuario,))
    results = cur.fetchall()
    cur.close()
    conn.close()

    return jsonify(results)


@api_bp.route('/api/categorize', methods=['POST'])
def categorize_transaction_api():
    """
    Clasificación rápida de transacción
    ---
    tags:
      - Categorización
    consumes:
      - application/json
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - description
          properties:
            description:
              type: string
              example: "Compra en OXXO valle oriente"
            amount:
              type: number
              example: 35
    responses:
      200:
        description: Resultado de categorización
        schema:
          type: object
          properties:
            success:
              type: boolean
            category:
              type: string
            confidence:
              type: integer
            reasoning:
              type: string
            is_gasto_hormiga:
              type: boolean
            suggestions:
              type: array
              items:
                type: string
      400:
        description: Error en la petición
      501:
        description: No implementado para IA
    """
    try:
        data = request.json or {}
        description = data.get("description")
        amount = data.get("amount", 0)

        if not description:
            return jsonify({"error": "description is required"}), 400

        quick_match = detect_category(description)
        if quick_match and quick_match["confidence"] >= 90:
            category = quick_match["category"]
            confidence = quick_match["confidence"]
            reasoning = f"Coincidencia directa con patrón: {quick_match['matchedPattern']}"
            is_gasto_hormiga = category == "Gasto Hormiga"
            suggestions = get_suggestions(category, amount)
            return jsonify({
                "success": True,
                "category": category,
                "confidence": confidence,
                "reasoning": reasoning,
                "is_gasto_hormiga": is_gasto_hormiga,
                "suggestions": suggestions
            }), 200

        else:
            return jsonify({"error": "Categoría no encontrada via patrones rápidos y IA no implementada aquí."}), 501

    except Exception as e:
        return jsonify({"error": str(e)}), 500

def detect_category(description):
    desc_lower = description.lower()
    for key, pattern in MERCHANT_CATEGORIES.items():
        for p in pattern["patterns"]:
            if p.lower() in desc_lower:
                return {
                    "category": pattern["category"],
                    "confidence": 95,
                    "matchedPattern": p,
                }
        for k in pattern["keywords"]:
            if k.lower() in desc_lower:
                return {
                    "category": pattern["category"],
                    "confidence": 75,
                    "matchedPattern": k,
                }
    return None

def get_suggestions(category, amount):
    suggestions_map = {
        "Gasto Hormiga": [
            "Considera preparar snacks en casa para ahorrar",
            "Lleva una botella de agua reutilizable",
            "Establece un presupuesto semanal para este tipo de gastos"
        ],
        "Transporte": [
            "Evalúa usar transporte público si es posible",
            "Considera compartir viajes con compañeros",
            "Revisa si tu ruta puede hacerse en bicicleta"
        ],
        "Alimentación": [
            "Este gasto parece alto, considera cocinar en casa" if amount > 200 else "Moderado, dentro de lo normal",
            "Planifica tus comidas semanalmente"
        ]
    }
    return suggestions_map.get(category, ["Mantén un registro de estos gastos"])

@api_bp.route('/api/feedback', methods=['POST'])
def submit_feedback():
    """
    Corregir categorización de transacción
    ---
    tags:
      - Feedback
    consumes:
      - application/json
    parameters:
      - in: body
        name: body
        required: true
        schema:
          type: object
          required:
            - transaction_id
            - corrected_category
            - cliente_id
          properties:
            transaction_id:
              type: integer
            corrected_category:
              type: string
            cliente_id:
              type: integer
    responses:
      200: 
        description: Feedback guardado
      400:
        description: Error en la petición
      500:
        description: Error interno del servidor
    """
    try:
        data = request.json or {}
        transaction_id = data.get('transaction_id')
        corrected_category = data.get('corrected_category')
        cliente_id = data.get('cliente_id')
        if not all([transaction_id, corrected_category, cliente_id]):
            return jsonify({'error': 'Faltan campos requeridos'}), 400

        conn = get_db_connection(); cur = conn.cursor(dictionary=True)
        cur.execute("SELECT category FROM FactTransacciones WHERE id_transaccion = %s", (transaction_id,))
        row = cur.fetchone()
        if not row:
            return jsonify({'error': 'Transacción no encontrada'}), 404

        original_category = row['category']
        cur.execute("""
            UPDATE FactTransacciones 
            SET category = %s, 
                category_feedback = %s,
                auto_categorized = 0,
                is_gasto_hormiga = CASE WHEN %s = 'Gasto Hormiga' THEN 1 ELSE 0 END
            WHERE id_transaccion = %s
        """, (corrected_category, corrected_category, corrected_category, transaction_id))

        cur.execute("""
            INSERT INTO categorization_feedback (transaction_id, original_category, corrected_category, cliente_id)
            VALUES (%s, %s, %s, %s)
        """, (transaction_id, original_category, corrected_category, cliente_id))

        conn.commit(); cur.close(); conn.close()
        return jsonify({'success': True, 'message': 'Feedback guardado correctamente'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


MERCHANT_CATEGORIES = {
    "gasto_hormiga": {
        "category": "Gasto Hormiga",
        "patterns": [
            "oxxo",
            "seven",
            "7-eleven",
            "7eleven",
            "extra",
            "kiosko",
            "tiendita",
            "minisuper",
            "starbucks",
            "tim hortons"
        ],
        "keywords": [
            "dulces",
            "snacks",
            "refresco",
            "cigarros",
            "botanas",
            "golosinas"
        ]
    },
    "transporte": {
        "category": "Transporte",
        "patterns": [
            "uber",
            "didi",
            "cabify",
            "metrorrey",
            "ecobici",
            "gasolina",
            "pemex",
            "shell"
        ],
        "keywords": ["viaje", "transporte", "taxi", "combustible"]
    },
    "alimentacion": {
        "category": "Alimentación",
        "patterns": [
            "mcdonalds",
            "burger",
            "subway",
            "dominos",
            "pizza",
            "restaurante",
            "taqueria",
            "tacos"
        ],
        "keywords": ["comida", "restaurante", "cafe", "food"]
    }
    # Agrega más categorías si las necesitas
}
