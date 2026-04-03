#!/bin/bash
# Deploy Workbench to tfs.is
# Run from the Workbench project root: ./deploy/deploy.sh

set -e

SERVER="tfs.is"
REMOTE_DIR="/opt/workbench"

echo "=== Deploying Workbench to $SERVER ==="

# 1. Create directory on server
echo "Creating remote directory..."
ssh $SERVER "mkdir -p $REMOTE_DIR/data"

# 2. Sync files (excluding git, deploy scripts, local data)
echo "Syncing files..."
rsync -avz --delete \
    --exclude '.git' \
    --exclude 'deploy/' \
    --exclude 'data/*.sqlite' \
    --exclude '*.fasl' \
    --exclude '*~' \
    ./ $SERVER:$REMOTE_DIR/

# 3. Install systemd service
echo "Installing systemd service..."
ssh $SERVER "cat > /etc/systemd/system/workbench.service << 'EOF'
[Unit]
Description=Workbench Operations System (Hunchentoot/Common Lisp)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/workbench
ExecStart=/usr/bin/sbcl --load /root/quicklisp/setup.lisp --load /opt/workbench/start.lisp --eval \"(loop (sleep 3600))\"
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"

ssh $SERVER "systemctl daemon-reload"

# 4. Add Caddy config if not already present
echo "Checking Caddy configuration..."
ssh $SERVER "grep -q 'workbench.paren.works' /etc/caddy/Caddyfile || cat >> /etc/caddy/Caddyfile << 'EOF'

workbench.paren.works {
    reverse_proxy localhost:8089
}
EOF"

# 5. Reload Caddy
echo "Reloading Caddy..."
ssh $SERVER "systemctl reload caddy"

# 6. Start/restart Workbench service
echo "Starting Workbench service..."
ssh $SERVER "systemctl enable workbench"
ssh $SERVER "systemctl restart workbench"

# 7. Check status
echo ""
echo "=== Deployment complete ==="
ssh $SERVER "systemctl status workbench --no-pager | head -15"

echo ""
echo "Workbench should be available at https://workbench.paren.works"
echo ""
echo "DNS Record needed (if not already set):"
echo "  Type: A    Host: workbench    Value: $(ssh $SERVER 'curl -s ifconfig.me')"
