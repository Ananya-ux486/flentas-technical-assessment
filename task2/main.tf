# Task 2: EC2 Static Website Hosting with Nginx
# This Terraform configuration deploys an EC2 instance with Nginx hosting a resume website

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "Ananya_Dixit"
}

# S3 Bucket to store resume PDF
resource "aws_s3_bucket" "resume_bucket" {
  bucket = "ananya-dixit-resume-${random_string.suffix.result}"

  tags = {
    Name = "${var.name_prefix}_Resume_Bucket"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Upload resume PDF to S3
resource "aws_s3_object" "resume_pdf" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "resume.pdf"
  source       = "${path.module}/Ananya dixit.pdf"
  content_type = "application/pdf"
}

# Make resume publicly accessible
resource "aws_s3_bucket_public_access_block" "resume_bucket" {
  bucket = aws_s3_bucket.resume_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "resume_bucket_policy" {
  bucket = aws_s3_bucket.resume_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.resume_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.resume_bucket]
}

# Data source to get the VPC from Task 1
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.name_prefix}_VPC"]
  }
}

# Data source to get public subnet from Task 1
data "aws_subnet" "public" {
  filter {
    name   = "tag:Name"
    values = ["${var.name_prefix}_Public_Subnet_1"]
  }
}

# Security Group for EC2 instance
resource "aws_security_group" "web_sg" {
  name        = "${var.name_prefix}_Web_SG"
  description = "Security group for web server - allows HTTP on port 80 and SSH"
  vpc_id      = data.aws_vpc.main.id

  # Allow HTTP on port 80
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH (restricted to your IP for security)
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change this to your IP for better security
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}_Web_SG"
  }
}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/setup-with-pdf.sh", {
    resume_url = "https://${aws_s3_bucket.resume_bucket.bucket_regional_domain_name}/resume.pdf"
  })

  depends_on = [aws_s3_object.resume_pdf]

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name = "${var.name_prefix}_Web_Server"
  }
}

# Outputs
output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web_server.id
}

output "instance_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "website_url" {
  description = "URL to access the website"
  value       = "http://${aws_instance.web_server.public_ip}"
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.web_sg.id
}

output "s3_bucket_name" {
  description = "S3 Bucket storing resume"
  value       = aws_s3_bucket.resume_bucket.id
}

output "resume_s3_url" {
  description = "Direct S3 URL to resume PDF"
  value       = "https://${aws_s3_bucket.resume_bucket.bucket_regional_domain_name}/resume.pdf"
}
