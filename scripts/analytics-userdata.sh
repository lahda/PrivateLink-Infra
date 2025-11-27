#!/bin/bash
# Analytics user-data (template variable: ${endpoint_dns})
set -e

ENDPOINT_DNS="${endpoint_dns}"

echo "[INFO] Starting Analytics client, endpoint: ${endpoint_dns}" >> /var/log/analytics-user-data.log
cat >/var/log/analytics-startup.txt <<EOF
Analytics client initialized on $(date)
API Endpoint DNS: ${endpoint_dns}
EOF

# Test script to query the API via the PrivateLink endpoint
cat > /home/ec2-user/test-api.sh << 'EOFTEST'
#!/bin/bash
ENDPOINT_DNS="${endpoint_dns}"

echo "Test connection to API endpoint: $ENDPOINT_DNS"
curl -s http://$ENDPOINT_DNS/ | jq .
EOFTEST

chmod +x /home/ec2-user/test-api.sh
chown ec2-user:ec2-user /home/ec2-user/test-api.sh

exit 0
