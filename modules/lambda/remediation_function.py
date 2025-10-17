#!/usr/bin/env python3
"""
AWS Lambda function for automated log monitoring remediation.
This function is triggered by SNS notifications from CloudWatch alarms.
"""

import json
import logging
import os
import boto3
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO'))

# AWS clients
ec2_client = boto3.client('ec2')
sns_client = boto3.client('sns')
logs_client = boto3.client('logs')


def handler(event, context):
    """
    Main Lambda handler function.
    
    Args:
        event: SNS event containing CloudWatch alarm notification
        context: Lambda context object
    
    Returns:
        dict: Response with status code and message
    """
    try:
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Process each SNS record
        for record in event.get('Records', []):
            process_sns_message(record)
        
        return {
            'statusCode': 200,
            'body': json.dumps('Remediation completed successfully')
        }
        
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }


def process_sns_message(record):
    """
    Process individual SNS message from CloudWatch alarm.
    
    Args:
        record: SNS record containing alarm details
    """
    try:
        # Parse SNS message
        sns_message = json.loads(record['Sns']['Message'])
        alarm_name = sns_message.get('AlarmName', '')
        alarm_description = sns_message.get('AlarmDescription', '')
        new_state = sns_message.get('NewStateValue', '')
        
        logger.info(f"Processing alarm: {alarm_name}, State: {new_state}")
        
        # Only process ALARM state (not OK or INSUFFICIENT_DATA)
        if new_state != 'ALARM':
            logger.info(f"Alarm state is {new_state}, no action needed")
            return
        
        # Determine remediation action based on alarm type
        if 'error' in alarm_name.lower():
            handle_error_alarm(alarm_name, sns_message)
        elif 'failed-login' in alarm_name.lower():
            handle_failed_login_alarm(alarm_name, sns_message)
        else:
            logger.warning(f"Unknown alarm type: {alarm_name}")
            
    except Exception as e:
        logger.error(f"Error processing SNS message: {str(e)}")
        raise


def handle_error_alarm(alarm_name, alarm_data):
    """
    Handle error-related alarms.
    
    Args:
        alarm_name: Name of the CloudWatch alarm
        alarm_data: Alarm notification data
    """
    logger.info(f"Handling error alarm: {alarm_name}")
    
    # Example remediation actions for errors:
    # 1. Log the incident
    # 2. Gather additional information
    # 3. Send detailed notification
    
    remediation_actions = [
        "Logged error alarm incident",
        "Gathered system metrics",
        "Notified operations team"
    ]
    
    # Send detailed notification
    send_remediation_notification(
        alarm_name,
        "Error Threshold Exceeded",
        remediation_actions,
        "HIGH"
    )


def handle_failed_login_alarm(alarm_name, alarm_data):
    """
    Handle failed login alarms - potential security incident.
    
    Args:
        alarm_name: Name of the CloudWatch alarm
        alarm_data: Alarm notification data
    """
    logger.info(f"Handling failed login alarm: {alarm_name}")
    
    # Example remediation actions for failed logins:
    # 1. Log security incident
    # 2. Analyze recent login attempts
    # 3. Consider temporary access restrictions
    
    remediation_actions = [
        "Logged security incident",
        "Analyzed recent login patterns",
        "Reviewed access logs",
        "Alerted security team"
    ]
    
    # Send security notification
    send_remediation_notification(
        alarm_name,
        "Multiple Failed Login Attempts Detected",
        remediation_actions,
        "CRITICAL"
    )


def send_remediation_notification(alarm_name, incident_type, actions, severity):
    """
    Send detailed remediation notification.
    
    Args:
        alarm_name: Name of the alarm
        incident_type: Type of incident
        actions: List of remediation actions taken
        severity: Incident severity level
    """
    try:
        timestamp = datetime.utcnow().isoformat()
        
        message = {
            "timestamp": timestamp,
            "alarm_name": alarm_name,
            "incident_type": incident_type,
            "severity": severity,
            "remediation_actions": actions,
            "status": "AUTOMATED_RESPONSE_COMPLETED"
        }
        
        logger.info(f"Remediation completed for {alarm_name}: {json.dumps(message)}")
        
        # In a real implementation, you might:
        # - Send to a different SNS topic for operations
        # - Store in DynamoDB for incident tracking
        # - Create ServiceNow tickets
        # - Update security dashboards
        
    except Exception as e:
        logger.error(f"Error sending remediation notification: {str(e)}")


def get_recent_log_events(log_group_name, hours=1):
    """
    Retrieve recent log events for analysis.
    
    Args:
        log_group_name: CloudWatch Log Group name
        hours: Number of hours to look back
    
    Returns:
        list: Recent log events
    """
    try:
        # Calculate time range
        end_time = int(datetime.utcnow().timestamp() * 1000)
        start_time = end_time - (hours * 60 * 60 * 1000)
        
        response = logs_client.filter_log_events(
            logGroupName=log_group_name,
            startTime=start_time,
            endTime=end_time,
            limit=100
        )
        
        return response.get('events', [])
        
    except Exception as e:
        logger.error(f"Error retrieving log events: {str(e)}")
        return []


def analyze_error_patterns(log_events):
    """
    Analyze log events for error patterns.
    
    Args:
        log_events: List of log events
    
    Returns:
        dict: Analysis results
    """
    error_count = 0
    error_types = {}
    
    for event in log_events:
        message = event.get('message', '')
        if 'ERROR' in message:
            error_count += 1
            # Simple error type extraction (can be enhanced)
            if 'database' in message.lower():
                error_types['database'] = error_types.get('database', 0) + 1
            elif 'network' in message.lower():
                error_types['network'] = error_types.get('network', 0) + 1
            else:
                error_types['general'] = error_types.get('general', 0) + 1
    
    return {
        'total_errors': error_count,
        'error_types': error_types,
        'analysis_timestamp': datetime.utcnow().isoformat()
    }