#!/bin/bash
# install-cloudwatch-agent.sh - Install and configure CloudWatch Agent on EC2

set -e

# Variables
REGION=${1:-us-west-2}
CONFIG_FILE="/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"

echo "Installing CloudWatch Agent..."

# Update system
sudo yum update -y

# Download and install CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm

# Create configuration directory
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

# Copy configuration file (assumes config is in current directory)
if [ -f "cloudwatch-agent-config.json" ]; then
    sudo cp cloudwatch-agent-config.json $CONFIG_FILE
    echo "Configuration file copied to $CONFIG_FILE"
else
    echo "Warning: cloudwatch-agent-config.json not found in current directory"
    echo "Please ensure the configuration file is available"
fi

# Start CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:$CONFIG_FILE

# Enable CloudWatch Agent to start on boot
sudo systemctl enable amazon-cloudwatch-agent

echo "CloudWatch Agent installation completed!"
echo "Agent status:"
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -m ec2 \
    -c file:$CONFIG_FILE \
    -a query

echo ""
echo "To generate test logs, run:"
echo "logger 'ERROR: Test error message for monitoring'"
echo "logger 'Failed login attempt from user testuser'"