# Flentas Technical Assessment

This repository contains my solutions for the Flentas Technical Assessment. Each task demonstrates AWS infrastructure implementation using Terraform.

**Author:** Ananya Dixit

---

## Repository Structure

```
flentas-aws-assessment/
├── task1/          # Networking & Subnetting (VPC Setup)
├── task2/          # (Coming soon)
├── task3/          # (Coming soon)
├── task4/          # (Coming soon)
└── task5/          # (Coming soon)
```

## Tasks Overview

### Task 1: Networking & Subnetting (AWS VPC Setup)
Created a complete VPC infrastructure with public and private subnets, Internet Gateway, and NAT Gateway for secure network architecture.

**Status:** ✅ Completed

### Task 2: EC2 Static Website Hosting
Deployed an EC2 instance with Nginx web server hosting a resume website. Implemented security hardening with encrypted EBS, IMDSv2, and proper security group configuration.

**Status:** ✅ Completed

### Task 3: High Availability + Auto Scaling
Migrated to a highly available architecture with Application Load Balancer, Auto Scaling Group (2-4 instances), and multi-AZ deployment for fault tolerance and automatic scaling.

**Status:** ✅ Completed

### Task 4: Billing & Free Tier Cost Monitoring
Configured CloudWatch billing alarms and Free Tier usage alerts to monitor AWS costs and prevent unexpected charges. Set up email notifications for budget thresholds.

**Status:** ✅ Completed

---

## Notes
- All AWS resources use the prefix `Ananya_Dixit_` for easy identification
- Infrastructure is deployed in the `us-east-1` region
- All resources will be cleaned up after assessment submission to avoid unnecessary charges

---

## Tools Used
- **Terraform** - Infrastructure as Code
- **AWS CLI** - AWS resource management
- **Git** - Version control

