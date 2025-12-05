terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
  # credentials come from environment (recommended) or shared config
  # AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY or profile
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
  description = "AWS region to create buckets in"
}

variable "test_prefix" {
  type    = string
  default = "tf-test-s3"
}

locals {
  timestamp = formatdate("YYYYMMDDHHMM", timestamp())
  base_name = "${var.test_prefix}-${local.timestamp}"
}

#############################################
# Insecure: public-read bucket (readable)   #
# Risk: data exposure, reconnaissance      #
#############################################
resource "aws_s3_bucket" "public_read_bucket" {
  bucket = "${local.base_name}-public-read"
  acl    = "public-read" # legacy ACL that makes objects readable by all
  force_destroy = true

  tags = {
    Name        = "public-read-bucket"
    Environment = "test"
  }
}

# Also attach an explicit wildcard policy granting GetObject to everyone
resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.public_read_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.public_read_bucket.arn}/*"
      }
    ]
  })
}

#############################################
# Insecure: public-read-write bucket (write)
# Risk: data tampering, malware hosting, DoS #
#############################################
resource "aws_s3_bucket" "public_read_write_bucket" {
  bucket = "${local.base_name}-public-rw"
  acl    = "public-read-write" # allows public uploads and read
  force_destroy = true

  tags = {
    Name        = "public-rw-bucket"
    Environment = "test"
  }
}

# Policy allowing PutObject to everyone (dangerous; for testing)
resource "aws_s3_bucket_policy" "public_write_policy" {
  bucket = aws_s3_bucket.public_read_write_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicWritePutObject"
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.public_read_write_bucket.arn}/*"
      }
    ]
  })
}

######################################
# Insecure: wildcard admin policy    #
# Risk: overly-broad permissions     #
######################################
resource "aws_s3_bucket" "wildcard_admin_bucket" {
  bucket = "${local.base_name}-wildcard-admin"
  acl    = "private"
  force_destroy = true

  tags = {
    Name        = "wildcard-admin-bucket"
    Environment = "test"
  }
}

resource "aws_s3_bucket_policy" "wildcard_admin_policy" {
  bucket = aws_s3_bucket.wildcard_admin_bucket.id

  # Grants s3:* to everyone — demonstrates overly permissive policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "DangerWildcard"
        Effect = "Allow"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.wildcard_admin_bucket.arn,
          "${aws_s3_bucket.wildcard_admin_bucket.arn}/*"
        ]
      }
    ]
  })
}

#####################################
# Insecure: bucket with no encryption
# Risk: plaintext storage of data    #
#####################################
resource "aws_s3_bucket" "no_encryption_bucket" {
  bucket = "${local.base_name}-no-encryption"
  acl    = "private"
  force_destroy = true

  tags = {
    Name        = "no-encryption-bucket"
    Environment = "test"
  }
}

####################################
# Insecure: bucket with no logging #
# Risk: forensic gaps              #
####################################
resource "aws_s3_bucket" "no_logging_bucket" {
  bucket = "${local.base_name}-no-logging"
  acl    = "private"
  force_destroy = true

  tags = {
    Name        = "no-logging-bucket"
    Environment = "test"
  }
}

#####################################
# Insecure: lifecycle disabled      #
# Risk: data retention / drift      #
#####################################
resource "aws_s3_bucket" "no_lifecycle_bucket" {
  bucket = "${local.base_name}-no-lifecycle"
  acl    = "private"
  force_destroy = true
}

########################################
# Helpful outputs for test automation  #
########################################
output "secure_bucket_name" {
  value = aws_s3_bucket.secure_bucket.bucket
}

output "public_read_bucket_name" {
  value = aws_s3_bucket.public_read_bucket.bucket
}

output "public_read_write_bucket_name" {
  value = aws_s3_bucket.public_read_write_bucket.bucket
}

output "wildcard_admin_bucket_name" {
  value = aws_s3_bucket.wildcard_admin_bucket.bucket
}

output "no_encryption_bucket_name" {
  value = aws_s3_bucket.no_encryption_bucket.bucket
}

output "no_logging_bucket_name" {
  value = aws_s3_bucket.no_logging_bucket.bucket
}

output "no_lifecycle_bucket_name" {
  value = aws_s3_bucket.no_lifecycle_bucket.bucket
}
