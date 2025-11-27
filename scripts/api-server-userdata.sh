#!/bin/bash
# Script d'initialisation pour API Server TechCorp

# Mise à jour du système
yum update -y

# Debug info: injected variables from Terraform
echo "LogGroup=${log_group_name} Region=${region}" >> /var/log/techcorp-api-install.log

# Installation de Python et Flask
yum install -y python3 python3-pip

# Installation de Flask
pip3 install flask

# Création du répertoire de l'application
mkdir -p /opt/techcorp-api
cd /opt/techcorp-api

# Création de l'application API
cat > /opt/techcorp-api/app.py << 'EOFAPP'
from flask import Flask, jsonify, request
import socket
import datetime

app = Flask(__name__)

# Simule une base de données de transactions
TRANSACTIONS_DB = [
    {"id": "TXN-001", "client": "ClientA", "montant": 15000, "statut": "validé", "date": "2025-11-15"},
    {"id": "TXN-002", "client": "ClientB", "montant": 28500, "statut": "en cours", "date": "2025-11-16"},
    {"id": "TXN-003", "client": "ClientC", "montant": 42000, "statut": "validé", "date": "2025-11-17"},
    {"id": "TXN-004", "client": "ClientD", "montant": 9800, "statut": "validé", "date": "2025-11-18"},
]

@app.route('/')
def home():
    return jsonify({
        "service": "TechCorp API Gateway",
        "version": "1.0.0",
        "department": "IT Production",
        "status": "operational"
    })

@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "hostname": socket.gethostname(),
        "timestamp": datetime.datetime.now().isoformat(),
        "service": "TechCorp Internal API"
    })

@app.route('/api/transactions', methods=['GET'])
def get_transactions():
    statut = request.args.get('statut')
    
    if statut:
        filtered = [t for t in TRANSACTIONS_DB if t['statut'] == statut]
        transactions = filtered
    else:
        transactions = TRANSACTIONS_DB
    
    return jsonify({
        "success": True,
        "count": len(transactions),
        "data": transactions,
        "server": socket.gethostname(),
        "accessed_via": "AWS PrivateLink"
    })

@app.route('/api/transactions/<transaction_id>', methods=['GET'])
def get_transaction(transaction_id):
    transaction = next((t for t in TRANSACTIONS_DB if t['id'] == transaction_id), None)
    
    if transaction:
        return jsonify({
            "success": True,
            "data": transaction,
            "server": socket.gethostname()
        })
    else:
        return jsonify({
            "success": False,
            "error": "Transaction non trouvée"
        }), 404

@app.route('/api/stats', methods=['GET'])
def get_stats():
    total_montant = sum(t['montant'] for t in TRANSACTIONS_DB)
    valides = len([t for t in TRANSACTIONS_DB if t['statut'] == 'validé'])
    
    return jsonify({
        "success": True,
        "statistiques": {
            "total_transactions": len(TRANSACTIONS_DB),
            "transactions_validees": valides,
            "montant_total": total_montant,
            "montant_moyen": total_montant / len(TRANSACTIONS_DB)
        },
        "server": socket.gethostname(),
        "department": "IT Production"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=False)
EOFAPP

# Création d'un service systemd
cat > /etc/systemd/system/techcorp-api.service << 'EOFSVC'
[Unit]
Description=TechCorp API Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/techcorp-api
ExecStart=/usr/bin/python3 /opt/techcorp-api/app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOFSVC

# Activation et démarrage
systemctl daemon-reload
systemctl enable techcorp-api
systemctl start techcorp-api

echo "API TechCorp démarrée!" > /var/log/techcorp-api-install.log
