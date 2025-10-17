#!/bin/bash
# test-monitoring.sh - Generate test logs to trigger monitoring alerts

set -e

echo "Generating test logs for monitoring system..."

# Function to generate error logs
generate_error_logs() {
    local count=${1:-6}
    echo "Generating $count error log entries..."
    
    for i in $(seq 1 $count); do
        logger "ERROR: Test error message $i - Database connection failed"
        sleep 2
    done
}

# Function to generate failed login logs
generate_failed_login_logs() {
    local count=${1:-4}
    echo "Generating $count failed login log entries..."
    
    for i in $(seq 1 $count); do
        logger "Failed login attempt from user testuser$i from IP 192.168.1.$i"
        sleep 2
    done
}

# Function to generate normal logs
generate_normal_logs() {
    local count=${1:-3}
    echo "Generating $count normal log entries..."
    
    for i in $(seq 1 $count); do
        logger "INFO: Normal application operation - User login successful"
        sleep 1
    done
}

# Main execution
echo "Starting log generation test..."
echo "This will generate logs to test the monitoring system"
echo ""

# Generate normal logs first
generate_normal_logs 3

echo "Waiting 10 seconds before generating error logs..."
sleep 10

# Generate error logs (should trigger error alarm)
generate_error_logs 6

echo "Waiting 30 seconds before generating failed login logs..."
sleep 30

# Generate failed login logs (should trigger failed login alarm)
generate_failed_login_logs 4

echo ""
echo "Test log generation completed!"
echo ""
echo "Expected results:"
echo "1. Error alarm should trigger (threshold: 5 errors in 5 minutes)"
echo "2. Failed login alarm should trigger (threshold: 3 failed logins in 5 minutes)"
echo "3. You should receive email notifications for both alarms"
echo "4. Lambda function should process the alerts (if enabled)"
echo ""
echo "Check the following:"
echo "- CloudWatch Logs: /aws/ec2/logs"
echo "- CloudWatch Alarms: Look for alarms in ALARM state"
echo "- Email: Check for SNS notifications"
echo "- Lambda Logs: /aws/lambda/log-monitoring-dev-remediation"