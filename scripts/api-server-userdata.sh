#!/bin/bash
# Script d'initialisation pour API Server TechCorp
#
# Les subnets du VPC Provider sont privés, sans NAT ni accès Internet :
# aucun "yum install" / "pip install" n'est possible ici. L'API utilise donc
# uniquement la bibliothèque standard Python (python3 est préinstallé sur AL2023).

exec >> /var/log/techcorp-api-install.log 2>&1

# Debug info: injected variables from Terraform
echo "LogGroup=${log_group_name} Region=${region}"

# Création du répertoire de l'application
mkdir -p /opt/techcorp-api

# Création de l'application API
cat > /opt/techcorp-api/app.py << 'EOFAPP'
import datetime
import json
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

# Simule une base de données de transactions
TRANSACTIONS_DB = [
    {"id": "TXN-001", "client": "ClientA", "montant": 15000, "statut": "validé", "date": "2025-11-15"},
    {"id": "TXN-002", "client": "ClientB", "montant": 28500, "statut": "en cours", "date": "2025-11-16"},
    {"id": "TXN-003", "client": "ClientC", "montant": 42000, "statut": "validé", "date": "2025-11-17"},
    {"id": "TXN-004", "client": "ClientD", "montant": 9800, "statut": "validé", "date": "2025-11-18"},
]


def home(query):
    return 200, {
        "service": "TechCorp API Gateway",
        "version": "1.0.0",
        "department": "IT Production",
        "status": "operational",
    }


def health(query):
    return 200, {
        "status": "healthy",
        "hostname": socket.gethostname(),
        "timestamp": datetime.datetime.now().isoformat(),
        "service": "TechCorp Internal API",
    }


def get_transactions(query):
    statut = query.get("statut", [None])[0]
    if statut:
        transactions = [t for t in TRANSACTIONS_DB if t["statut"] == statut]
    else:
        transactions = TRANSACTIONS_DB
    return 200, {
        "success": True,
        "count": len(transactions),
        "data": transactions,
        "server": socket.gethostname(),
        "accessed_via": "AWS PrivateLink",
    }


def get_transaction(transaction_id):
    transaction = next((t for t in TRANSACTIONS_DB if t["id"] == transaction_id), None)
    if transaction:
        return 200, {"success": True, "data": transaction, "server": socket.gethostname()}
    return 404, {"success": False, "error": "Transaction non trouvée"}


def get_stats(query):
    total_montant = sum(t["montant"] for t in TRANSACTIONS_DB)
    valides = len([t for t in TRANSACTIONS_DB if t["statut"] == "validé"])
    return 200, {
        "success": True,
        "statistiques": {
            "total_transactions": len(TRANSACTIONS_DB),
            "transactions_validees": valides,
            "montant_total": total_montant,
            "montant_moyen": total_montant / len(TRANSACTIONS_DB),
        },
        "server": socket.gethostname(),
        "department": "IT Production",
    }


ROUTES = {
    "/": home,
    "/health": health,
    "/api/transactions": get_transactions,
    "/api/stats": get_stats,
}


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        url = urlparse(self.path)
        path = url.path.rstrip("/") or "/"
        query = parse_qs(url.query)

        if path in ROUTES:
            status, body = ROUTES[path](query)
        elif path.startswith("/api/transactions/"):
            status, body = get_transaction(path[len("/api/transactions/"):])
        else:
            status, body = 404, {"success": False, "error": "Not found"}

        payload = json.dumps(body, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)


if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", 80), Handler).serve_forever()
EOFAPP

# Création d'un service systemd
cat > /etc/systemd/system/techcorp-api.service << 'EOFSVC'
[Unit]
Description=TechCorp API Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/techcorp-api
ExecStart=/usr/bin/python3 /opt/techcorp-api/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOFSVC

# Activation et démarrage
systemctl daemon-reload
systemctl enable --now techcorp-api

echo "API TechCorp démarrée!"
