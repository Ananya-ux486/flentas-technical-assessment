# Task 4: Billing & Free Tier Cost Monitoring
# This Terraform configuration creates CloudWatch billing alarms

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Billing alarms MUST be created in us-east-1 region
provider "aws" {
  region = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "Ananya_Dixit"
}

variable "alert_email" {
  description = "Email address for billing alerts"
  type        = string
  default     = "ananya.19543@gmail.com"
}

variable "billing_threshold" {
  description = "Billing threshold in USD (₹100 ≈ $1.20)"
  type        = number
  default     = 1.20
}

# SNS Topic for billing alerts
resource "aws_sns_topic" "billing_alerts" {
  name = "${var.name_prefix}_Billing_Alerts"

  tags = {
    Name = "${var.name_prefix}_Billing_Alerts"
  }
}

# SNS Topic Subscription (Email)
resource "aws_sns_topic_subscription" "billing_alerts_email" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Billing Alarm
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "${var.name_prefix}_Billing_Alert_100_Rupees"
  alarm_description   = "Alert when estimated charges exceed ₹100 (approximately $${var.billing_threshold})"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600 # 6 hours
  statistic           = "Maximum"
  threshold           = var.billing_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [aws_sns_topic.billing_alerts.arn]

  tags = {
    Name = "${var.name_prefix}_Billing_Alarm"
  }
}

# Additional alarm at 50% threshold (₹50)
resource "aws_cloudwatch_metric_alarm" "billing_alarm_50_percent" {
  alarm_name          = "${var.name_prefix}_Billing_Alert_50_Rupees"
  alarm_description   = "Warning when estimated charges exceed ₹50 (approximately $${var.billing_threshold / 2})"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600
  statistic           = "Maximum"
  threshold           = var.billing_threshold / 2
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [aws_sns_topic.billing_alerts.arn]

  tags = {
    Name = "${var.name_prefix}_Billing_Alarm_50"
  }
}

# Outputs
output "sns_topic_arn" {
  description = "ARN of the SNS topic for billing alerts"
  value       = aws_sns_topic.billing_alerts.arn
}

output "billing_alarm_name" {
  description = "Name of the main billing alarm"
  value       = aws_cloudwatch_metric_alarm.billing_alarm.alarm_name
}

output "email_subscription_note" {
  description = "Important note about email confirmation"
  value       = "IMPORTANT: Check your email (${var.alert_email}) and confirm the SNS subscription to receive alerts!"
}

output "cloudwatch_console_url" {
  description = "URL to view alarms in CloudWatch console"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#alarmsV2:"
}
