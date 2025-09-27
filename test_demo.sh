#!/bin/bash

echo "🔒 Falco Runtime Security Demo - Test Execution"
echo "==============================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Start Falco log monitoring in background
echo "📊 Monitoring Falco alerts..."
docker logs -f falco 2>&1 | grep -E "Warning|Critical" > falco_alerts.log &
FALCO_PID=$!

sleep 3

echo "Test 1: Normal Query (No Alert Expected)"
echo "----------------------------------------"
curl -s http://localhost:5000/users | jq .
echo -e "${GREEN}✓ Normal query executed${NC}"
sleep 3

echo ""
echo "Test 2: Reading /etc/passwd (WARNING Expected)"
echo "----------------------------------------------"
curl -s http://localhost:5000/trigger-file-read | jq .
echo -e "${YELLOW}⚠ Triggered /etc/passwd read${NC}"
sleep 4

echo ""
echo "Test 3: SELECT * FROM PII (CRITICAL Expected)"
echo "---------------------------------------------"
curl -s -X POST http://localhost:5000/run-sql \
  -H "Content-Type: application/json" \
  -d '{"query":"SELECT * FROM PII"}' | jq .
echo -e "${RED}🚨 Triggered SELECT * on PII table${NC}"
sleep 4

echo ""
echo "Test 4: Direct PII Query"
echo "------------------------"
curl -s http://localhost:5000/trigger-pii-query | jq .
echo -e "${YELLOW}⚠ Triggered PII table access${NC}"
sleep 4

# Kill background process
kill $FALCO_PID 2>/dev/null

echo ""
echo "📋 Falco Alerts Detected:"
echo "========================"
if [ -f falco_alerts.log ] && [ -s falco_alerts.log ]; then
    cat falco_alerts.log
else
    echo "Checking Falco logs directly..."
    docker logs falco 2>&1 | grep -E "Warning|Critical" | tail -20
fi

echo ""
echo "📊 JSON Format Alerts:"
echo "====================="
docker logs falco 2>&1 | grep -E "Warning|Critical" | head -5 | jq . 2>/dev/null || echo "Use: docker logs falco | jq . for JSON format"

echo ""
echo "✅ Test Complete!"
echo ""
echo "To view all Falco logs: docker logs falco | jq ."
echo "To save alerts: docker logs falco | jq 'select(.priority==\"Warning\" or .priority==\"Critical\")' > alerts.json"