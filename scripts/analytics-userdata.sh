#!/bin/bash
# Analytics user-data (template variable: ${endpoint_dns})

exec >> /var/log/analytics-user-data.log 2>&1

echo "[INFO] Starting Analytics client, endpoint: ${endpoint_dns}"
cat >/var/log/analytics-startup.txt <<EOF
Analytics client initialized on $(date)
API Endpoint DNS: ${endpoint_dns}
EOF

# jq is only used for pretty-printing (the consumer public subnet has Internet access)
dnf install -y jq || echo "[WARN] jq install failed, raw JSON will be shown"

# Test script to query the API via the PrivateLink endpoint
cat > /home/ec2-user/test-api.sh << 'EOFTEST'
#!/bin/bash
ENDPOINT_DNS="${endpoint_dns}"

pretty() { if command -v jq >/dev/null 2>&1; then jq .; else cat; echo; fi; }

echo "Test connection to API endpoint: $ENDPOINT_DNS"
for path in / /health /api/transactions /api/stats /api/transactions/TXN-001; do
  echo "=== GET $path"
  curl -sS --max-time 5 "http://$ENDPOINT_DNS$path" | pretty
done
EOFTEST

chmod +x /home/ec2-user/test-api.sh
chown ec2-user:ec2-user /home/ec2-user/test-api.sh
