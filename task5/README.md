# Task 5: AWS Architecture Diagram (draw.io)

## Architecture Overview

This architecture is designed to handle 10,000 concurrent users with high availability, scalability, and security. The design follows AWS best practices for a production-grade web application.

## My Architecture Explanation

For this highly scalable web application, I designed a three-tier architecture spread across multiple availability zones. Users access the application through Route 53 DNS, which directs traffic to CloudFront CDN for static content delivery and caching at edge locations worldwide. Dynamic requests go through an Application Load Balancer in public subnets, which distributes traffic across an Auto Scaling Group of EC2 instances in private subnets. The application tier connects to Amazon RDS (Multi-AZ) for relational data and ElastiCache (Redis) for session management and caching, both in private subnets. For security, I've implemented multiple layers including WAF at the CloudFront level, Security Groups and NACLs for network isolation, and AWS Secrets Manager for credential management. CloudWatch monitors all components with alarms for proactive issue detection, while CloudTrail logs all API calls for audit purposes. S3 stores static assets and application logs with lifecycle policies for cost optimization.

## Architecture Components

### 1. Load Balancing (ALB)
- **Application Load Balancer** in public subnets across 2 AZs
- Distributes traffic to EC2 instances
- SSL/TLS termination
- Health checks every 30 seconds

### 2. Auto Scaling Group
- **Min: 4, Max: 20, Desired: 6** instances
- Scales based on CPU utilization (target: 70%)
- Spread across 2 availability zones
- Uses Launch Template with latest AMI

### 3. Multi-tier Networking
**VPC: 10.0.0.0/16**
- **Public Subnets** (10.0.1.0/24, 10.0.2.0/24): ALB, NAT Gateways
- **Private App Subnets** (10.0.11.0/24, 10.0.12.0/24): EC2 instances
- **Private DB Subnets** (10.0.21.0/24, 10.0.22.0/24): RDS, ElastiCache
- **2 Availability Zones** for high availability

### 4. Scalable Database Layer
- **Amazon RDS (PostgreSQL)** - Multi-AZ deployment
  - Primary in AZ-A, Standby in AZ-B
  - Automated backups, point-in-time recovery
  - Read replicas for read-heavy workloads
- **Amazon Aurora** (alternative) - Serverless v2 for auto-scaling

### 5. Caching Layer
- **Amazon ElastiCache (Redis)** - Cluster mode enabled
  - Session storage
  - Database query caching
  - Real-time analytics
  - Multi-AZ with automatic failover

### 6. Security Components
- **AWS WAF** - Web Application Firewall
  - SQL injection protection
  - XSS attack prevention
  - Rate limiting (10,000 requests/5 min per IP)
- **Security Groups** - Stateful firewall
  - ALB SG: Allow 80/443 from internet
  - App SG: Allow traffic only from ALB
  - DB SG: Allow traffic only from App tier
- **Network ACLs** - Subnet-level firewall
- **AWS Secrets Manager** - Database credentials
- **AWS Certificate Manager** - SSL/TLS certificates

### 7. Observability
- **Amazon CloudWatch**
  - Metrics: CPU, Memory, Network, Custom app metrics
  - Logs: Application logs, Access logs, Error logs
  - Alarms: CPU > 80%, Memory > 85%, 5xx errors
  - Dashboards: Real-time monitoring
- **AWS CloudTrail** - API audit logging
- **AWS X-Ray** - Distributed tracing

### 8. Additional Services
- **Amazon CloudFront** - CDN for static content
  - Edge caching (TTL: 24 hours)
  - HTTPS enforcement
  - Origin failover
- **Amazon S3**
  - Static assets (images, CSS, JS)
  - Application logs
  - Database backups
  - Lifecycle policies (move to Glacier after 90 days)
- **Amazon Route 53** - DNS with health checks
- **AWS Systems Manager** - Parameter Store, Session Manager
- **Amazon SNS** - Alert notifications
- **AWS Backup** - Centralized backup management

## Traffic Flow

1. **User Request** → Route 53 DNS resolution
2. **Route 53** → CloudFront (for static content) OR ALB (for dynamic content)
3. **CloudFront** → S3 (cache miss) OR Edge cache (cache hit)
4. **ALB** → Target Group → Healthy EC2 instance (private subnet)
5. **EC2 Instance** → ElastiCache (check cache)
6. **Cache Miss** → RDS database query
7. **Response** → Cache result → Return to user
8. **Outbound traffic** → NAT Gateway → Internet Gateway

## Scalability Features

**Horizontal Scaling:**
- Auto Scaling Group: 4-20 instances based on demand
- RDS Read Replicas: Up to 15 replicas
- ElastiCache: Cluster mode with multiple shards

**Vertical Scaling:**
- RDS: Can upgrade instance type with minimal downtime
- ElastiCache: Can change node types

**Geographic Scaling:**
- CloudFront: 450+ edge locations worldwide
- Route 53: Latency-based routing

## High Availability Features

- **Multi-AZ deployment** for all critical components
- **RDS Multi-AZ** with automatic failover (< 2 minutes)
- **ElastiCache Multi-AZ** with automatic failover
- **ALB** distributes across multiple AZs
- **S3** - 99.999999999% durability
- **CloudFront** - Automatic failover to secondary origin

## Security Best Practices

1. **Defense in Depth**: Multiple security layers (WAF, SG, NACL)
2. **Least Privilege**: IAM roles with minimal permissions
3. **Encryption**: At rest (EBS, RDS, S3) and in transit (TLS)
4. **Secrets Management**: No hardcoded credentials
5. **Network Isolation**: Private subnets for app and database tiers
6. **Monitoring**: CloudWatch alarms for security events
7. **Compliance**: CloudTrail for audit logging

## Cost Optimization

- **Auto Scaling**: Scale down during low traffic
- **Reserved Instances**: For baseline capacity (40% savings)
- **S3 Lifecycle**: Move old data to Glacier
- **CloudFront**: Reduce origin requests
- **RDS**: Use appropriate instance size
- **ElastiCache**: Right-size cluster based on usage

## Estimated Monthly Cost (10,000 concurrent users)

| Service | Configuration | Monthly Cost |
|---------|--------------|--------------|
| EC2 (6 x t3.large) | Reserved Instances | ~$250 |
| ALB | 2 AZs | ~$25 |
| RDS (db.r5.xlarge) | Multi-AZ | ~$450 |
| ElastiCache (cache.r5.large) | 2 nodes | ~$200 |
| CloudFront | 1TB data transfer | ~$85 |
| S3 | 500GB storage | ~$12 |
| NAT Gateway | 2 AZs | ~$65 |
| Route 53 | Hosted zone + queries | ~$5 |
| CloudWatch | Logs + Metrics | ~$30 |
| **Total** | | **~$1,122/month** |

## Diagram Instructions for draw.io

### Step 1: Open draw.io
Go to https://app.diagrams.net/

### Step 2: Create New Diagram
- Click "Create New Diagram"
- Choose "Blank Diagram"
- Name it: "AWS-Architecture-10000-Users"

### Step 3: Add AWS Shapes
- Click "More Shapes" (bottom left)
- Search for "AWS 19"
- Enable "AWS 19" shape library
- Click "Apply"

### Step 4: Layout Structure (Top to Bottom)

**Layer 1 - Users & DNS:**
- Add "Users" icon (from General shapes)
- Add "Route 53" icon
- Add "CloudFront" icon

**Layer 2 - Edge Security:**
- Add "AWS WAF" icon

**Layer 3 - VPC Container:**
- Draw a large rectangle (VPC boundary)
- Label: "VPC 10.0.0.0/16"

**Layer 4 - Public Subnets (inside VPC):**
- Draw 2 rectangles side by side
- Label: "Public Subnet AZ-A" and "Public Subnet AZ-B"
- Add "Application Load Balancer" spanning both
- Add "NAT Gateway" in each subnet

**Layer 5 - Private App Subnets:**
- Draw 2 rectangles below public subnets
- Label: "Private App Subnet AZ-A" and "Private App Subnet AZ-B"
- Add "Auto Scaling Group" icon
- Add 3 "EC2" icons in each subnet

**Layer 6 - Private DB Subnets:**
- Draw 2 rectangles below app subnets
- Label: "Private DB Subnet AZ-A" and "Private DB Subnet AZ-B"
- Add "RDS" icon (Multi-AZ)
- Add "ElastiCache" icon

**Layer 7 - Supporting Services (Right side):**
- Add "S3" icon
- Add "CloudWatch" icon
- Add "CloudTrail" icon
- Add "Secrets Manager" icon
- Add "SNS" icon

**Layer 8 - Security Groups (as dotted boxes):**
- Draw dotted rectangles around ALB, EC2, RDS
- Label: "ALB-SG", "App-SG", "DB-SG"

### Step 5: Add Connections (Arrows)
- Users → Route 53 → CloudFront → WAF → ALB
- ALB → EC2 instances
- EC2 → ElastiCache (dashed line for cache)
- EC2 → RDS (solid line for database)
- EC2 → S3 (for static assets)
- All components → CloudWatch (monitoring)
- NAT Gateway → Internet Gateway (outbound)

### Step 6: Add Labels and Colors
- Use AWS orange (#FF9900) for AWS services
- Use blue for network components
- Use green for security components
- Add text labels for CIDR blocks, ports, protocols

### Step 7: Export
- File → Export as → PNG (or PDF)
- Resolution: 300 DPI
- Transparent background: No
- Save as: `aws-architecture-diagram.png`

## Alternative: Text-Based Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         USERS (10,000)                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   Route 53 DNS  │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
     ┌────────▼────────┐          ┌────────▼────────┐
     │   CloudFront    │          │    AWS WAF      │
     │   (CDN/Cache)   │          │  (Firewall)     │
     └────────┬────────┘          └────────┬────────┘
              │                             │
              │                    ┌────────▼────────┐
              │                    │  Application    │
              │                    │  Load Balancer  │
              │                    │  (Public Subnet)│
              │                    └────────┬────────┘
              │                             │
┌─────────────┴─────────────────────────────┴──────────────────────┐
│                         VPC (10.0.0.0/16)                        │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Auto Scaling Group (4-20)                   │   │
│  │  ┌─────────────────────┐    ┌─────────────────────┐     │   │
│  │  │  Private Subnet AZ-A│    │  Private Subnet AZ-B│     │   │
│  │  │  ┌────┐ ┌────┐ ┌────┐    │  ┌────┐ ┌────┐ ┌────┐     │   │
│  │  │  │EC2 │ │EC2 │ │EC2 │    │  │EC2 │ │EC2 │ │EC2 │     │   │
│  │  │  └─┬──┘ └─┬──┘ └─┬──┘    │  └─┬──┘ └─┬──┘ └─┬──┘     │   │
│  │  └────┼──────┼──────┼────────┴────┼──────┼──────┼───────┘   │
│  └───────┼──────┼──────┼─────────────┼──────┼──────┼───────────┘
│          │      │      │             │      │      │            │
│          └──────┴──────┴─────┬───────┴──────┴──────┘            │
│                              │                                   │
│                    ┌─────────▼──────────┐                        │
│                    │   ElastiCache      │                        │
│                    │   (Redis Cluster)  │                        │
│                    │   Private Subnet   │                        │
│                    └─────────┬──────────┘                        │
│                              │                                   │
│                    ┌─────────▼──────────┐                        │
│                    │   RDS Multi-AZ     │                        │
│                    │   (PostgreSQL)     │                        │
│                    │   Private Subnet   │                        │
│                    └────────────────────┘                        │
│                                                                   │
│  ┌──────────────┐                          ┌──────────────┐     │
│  │ NAT Gateway  │                          │ NAT Gateway  │     │
│  │   (AZ-A)     │                          │   (AZ-B)     │     │
│  └──────┬───────┘                          └──────┬───────┘     │
└─────────┼──────────────────────────────────────────┼────────────┘
          │                                          │
          └──────────────┬───────────────────────────┘
                         │
                ┌────────▼────────┐
                │ Internet Gateway│
                └─────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Supporting Services                          │
├─────────────────────────────────────────────────────────────────┤
│  S3 (Static Assets) │ CloudWatch (Monitoring) │ SNS (Alerts)   │
│  CloudTrail (Audit) │ Secrets Manager (Creds) │ X-Ray (Trace)  │
└─────────────────────────────────────────────────────────────────┘
```

## Key Design Decisions

1. **Why Multi-AZ?** - Ensures 99.99% availability even if one AZ fails
2. **Why ElastiCache?** - Reduces database load by 70-80%, improves response time
3. **Why CloudFront?** - Reduces latency for global users, saves bandwidth costs
4. **Why Private Subnets?** - Security best practice, prevents direct internet access
5. **Why Auto Scaling 4-20?** - Handles traffic spikes while optimizing costs
6. **Why RDS Multi-AZ?** - Automatic failover in < 2 minutes, no data loss

## Performance Metrics

- **Response Time**: < 200ms (with caching)
- **Availability**: 99.99% uptime
- **Concurrent Users**: 10,000+ supported
- **Requests/Second**: ~5,000 RPS
- **Database Connections**: 1,000 max
- **Cache Hit Ratio**: 85%+

## Disaster Recovery

- **RTO (Recovery Time Objective)**: < 5 minutes
- **RPO (Recovery Point Objective)**: < 5 minutes
- **Backup Strategy**: Automated daily backups, 7-day retention
- **Failover**: Automatic for RDS and ElastiCache
