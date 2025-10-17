# AWS Log Monitoring System - Visual Architecture

## System Architecture Diagram

```mermaid
graph TB
    subgraph "AWS Cloud"
        subgraph "EC2 Layer"
            EC2_1[EC2 Instance 1<br/>CloudWatch Agent]
            EC2_2[EC2 Instance 2<br/>CloudWatch Agent]
            EC2_3[EC2 Instance N<br/>CloudWatch Agent]
        end
        
        subgraph "Logging Layer"
            CWL[CloudWatch Logs<br/>/aws/ec2/logs<br/>Retention: 7 days]
        end
        
        subgraph "Monitoring Layer"
            MF1[Metric Filter<br/>ERROR Pattern]
            MF2[Metric Filter<br/>Failed Login Pattern]
            
            CWA1[CloudWatch Alarm<br/>Error Threshold: ≥5]
            CWA2[CloudWatch Alarm<br/>Failed Login: ≥3]
        end
        
        subgraph "Notification Layer"
            SNS[SNS Topic<br/>Alert Notifications]
        end
        
        subgraph "Response Layer"
            EMAIL[Email Alerts]
            LAMBDA[Lambda Function<br/>Automated Remediation]
        end
        
        subgraph "Visualization Layer"
            DASH[CloudWatch Dashboard<br/>Real-time Monitoring]
        end
        
        subgraph "Security Layer"
            IAM1[CloudWatch Agent Role<br/>EC2 Instance Profile]
            IAM2[Lambda Execution Role<br/>Remediation Permissions]
        end
    end
    
    subgraph "External"
        USER[Operations Team<br/>Email Notifications]
    end
    
    %% Data Flow
    EC2_1 --> CWL
    EC2_2 --> CWL
    EC2_3 --> CWL
    
    CWL --> MF1
    CWL --> MF2
    
    MF1 --> CWA1
    MF2 --> CWA2
    
    CWA1 --> SNS
    CWA2 --> SNS
    
    SNS --> EMAIL
    SNS --> LAMBDA
    
    EMAIL --> USER
    
    CWL --> DASH
    CWA1 --> DASH
    CWA2 --> DASH
    
    %% Security Relationships
    IAM1 -.-> EC2_1
    IAM1 -.-> EC2_2
    IAM1 -.-> EC2_3
    IAM2 -.-> LAMBDA
    
    %% Styling
    classDef ec2 fill:#ff9999
    classDef monitoring fill:#99ccff
    classDef notification fill:#99ff99
    classDef security fill:#ffcc99
    
    class EC2_1,EC2_2,EC2_3 ec2
    class CWL,MF1,MF2,CWA1,CWA2,DASH monitoring
    class SNS,EMAIL,LAMBDA notification
    class IAM1,IAM2 security
```

## Component Details

### 1. Log Collection (EC2 Layer)
- **EC2 Instances**: Multiple instances running applications
- **CloudWatch Agent**: Installed on each instance to collect logs
- **Log Sources**: Application logs, system logs (/var/log/*), security logs

### 2. Log Storage (Logging Layer)
- **CloudWatch Logs**: Centralized log storage
- **Log Groups**: Organized by application/service
- **Retention Policy**: Configurable (default: 7 days)
- **Encryption**: Optional KMS encryption

### 3. Pattern Detection (Monitoring Layer)
- **Metric Filters**: Real-time log pattern analysis
  - Error Filter: Detects "ERROR" patterns
  - Security Filter: Detects "Failed login" patterns
- **Custom Metrics**: Generated from matched patterns
- **CloudWatch Alarms**: Monitor metric thresholds

### 4. Alert Distribution (Notification Layer)
- **SNS Topic**: Central notification hub
- **Multiple Subscribers**: Email, Lambda, future integrations
- **Message Routing**: Based on alarm type and severity

### 5. Automated Response (Response Layer)
- **Email Notifications**: Immediate alerts to operations team
- **Lambda Function**: Automated incident response
  - Log analysis and correlation
  - Automated remediation actions
  - Detailed incident reporting

### 6. Monitoring Dashboard (Visualization Layer)
- **CloudWatch Dashboard**: Real-time system overview
- **Metrics Visualization**: Error trends, login patterns
- **Log Insights**: Advanced log querying and analysis

### 7. Security (Security Layer)
- **IAM Roles**: Least privilege access control
- **Instance Profiles**: Secure EC2 access to CloudWatch
- **Lambda Execution Role**: Controlled remediation permissions

## Data Flow Sequence

```mermaid
sequenceDiagram
    participant EC2 as EC2 Instance
    participant CWA as CloudWatch Agent
    participant CWL as CloudWatch Logs
    participant MF as Metric Filter
    participant ALM as CloudWatch Alarm
    participant SNS as SNS Topic
    participant EMAIL as Email Alert
    participant LAMBDA as Lambda Function
    
    EC2->>CWA: Generate application logs
    CWA->>CWL: Send log events
    CWL->>MF: Process log patterns
    MF->>ALM: Update custom metrics
    
    alt Threshold Exceeded
        ALM->>SNS: Trigger alarm notification
        SNS->>EMAIL: Send email alert
        SNS->>LAMBDA: Invoke remediation function
        LAMBDA->>LAMBDA: Analyze incident
        LAMBDA->>LAMBDA: Execute remediation
        LAMBDA->>SNS: Send detailed report
    end
```

## Security Architecture

```mermaid
graph LR
    subgraph "IAM Security Model"
        subgraph "EC2 Security"
            ROLE1[CloudWatch Agent Role]
            PROF1[Instance Profile]
            POL1[CloudWatch Logs Policy]
        end
        
        subgraph "Lambda Security"
            ROLE2[Lambda Execution Role]
            POL2[Basic Execution Policy]
            POL3[Remediation Policy]
        end
        
        subgraph "Service Security"
            SNS_POL[SNS Topic Policy]
            CWL_POL[CloudWatch Logs Policy]
        end
    end
    
    ROLE1 --> PROF1
    ROLE1 --> POL1
    ROLE2 --> POL2
    ROLE2 --> POL3
    
    POL1 -.-> CWL_POL
    POL3 -.-> SNS_POL
```

## Deployment Architecture

```mermaid
graph TB
    subgraph "Terraform Modules"
        subgraph "IAM Module"
            IAM_MAIN[main.tf<br/>Roles & Policies]
            IAM_VAR[variables.tf]
            IAM_OUT[outputs.tf]
        end
        
        subgraph "Monitoring Module"
            MON_MAIN[main.tf<br/>CloudWatch & SNS]
            MON_VAR[variables.tf]
            MON_OUT[outputs.tf]
        end
        
        subgraph "Lambda Module"
            LAM_MAIN[main.tf<br/>Function & Triggers]
            LAM_VAR[variables.tf]
            LAM_OUT[outputs.tf]
            LAM_CODE[remediation_function.py]
        end
    end
    
    subgraph "Root Configuration"
        MAIN[main.tf<br/>Module Integration]
        VARS[variables.tf<br/>Input Variables]
        OUTPUTS[outputs.tf<br/>System Outputs]
        BACKEND[backend.tf<br/>Remote State]
    end
    
    MAIN --> IAM_MAIN
    MAIN --> MON_MAIN
    MAIN --> LAM_MAIN
    
    VARS --> IAM_VAR
    VARS --> MON_VAR
    VARS --> LAM_VAR
    
    IAM_OUT --> OUTPUTS
    MON_OUT --> OUTPUTS
    LAM_OUT --> OUTPUTS
```

## Cost Optimization Strategy

| Component | Cost Factor | Optimization |
|-----------|-------------|--------------|
| CloudWatch Logs | Log volume & retention | Configurable retention (7-30 days) |
| CloudWatch Metrics | Custom metrics | Efficient metric filters |
| CloudWatch Alarms | Number of alarms | Consolidated alarm strategy |
| SNS | Message volume | Targeted notifications |
| Lambda | Execution time & memory | Optimized function code |
| Data Transfer | Cross-AZ traffic | Regional deployment |

## Scalability Considerations

- **Horizontal Scaling**: Support for multiple EC2 instances
- **Log Volume**: Handles high-volume log ingestion
- **Alarm Scaling**: Configurable thresholds per environment
- **Geographic Distribution**: Multi-region deployment ready
- **Performance**: Sub-minute alert response time