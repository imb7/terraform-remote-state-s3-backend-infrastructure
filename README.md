# Terraform Backend Infrastructure

This repository provisions a shared remote backend for Terraform projects on AWS, including an S3 bucket for state and optional DynamoDB table for state locking; the main branch uses S3 native locking, while the dynamoDB_locking branch provides legacy DynamoDB-based locking.

## Overview

This project creates the foundational backend resources used by other Terraform configurations, an S3 bucket for remote state, server-side encryption, versioning, and optional DynamoDB table for state locks. The preferred approach is S3 native locking, which avoids the need to provision DynamoDB and simplifies permissions and operations.

**Branches**
1. main: Uses S3 native locking with use_lockfile = true in the S3 backend; no DynamoDB table is required or created.

2. dynamoDB_locking: Uses a DynamoDB table for state locking; kept for legacy compatibility and migration scenarios.

**Architecture**
* S3 state bucket: Private, versioned, and encrypted (SSE-S3 or KMS if configured), intended to store Terraform state per environment/prefix.

* Locking:

    1. Native S3 locking (main): lockfiles are stored alongside the state object; no extra AWS resources are   1. needed.

    2. DynamoDB locking (legacy branch): a dedicated table manages state locks for concurrency control.

**Prerequisites**
* Terraform CLI: Version compatible with S3 native locking (recommend current stable 1.13.0+).

* AWS access: CLI credentials or role access with permissions to create and manage S3 bucket, optional DynamoDB table, and to read/write/delete state and lock objects.

* IAM permissions: s3:CreateBucket, s3:PutBucketVersioning, s3:PutEncryptionConfiguration, s3:PutBucketPolicy (if used), s3:GetObject, s3:PutObject, s3:DeleteObject; for legacy branch, dynamodb:CreateTable and standard CRUD on the lock table.

**Usage**
1. Clone and select a branch

2. Preferred (S3 native locking):
    git checkout main

3. Legacy (DynamoDB locking):
    git checkout dynamoDB_locking

4. Configure variables

    Set bucket name, region, optional KMS key, and table name (legacy) via terraform.tfvars or  environment-specific files.

5. Deploy backend resources

    * Initialize:
        terraform init

    * Review:
        terraform plan -var-file=terraform.tfvars

    * Apply:
        terraform apply -var-file=terraform.tfvars

**Backend configuration examples**
Add one of the following to downstream Terraform projects.

* S3 native locking (preferred, main):

<pre>
    terraform {
      backend "s3" {
        bucket       = "org-tf-state"
        key          = "platform/shared/backend.tfstate"
        region       = "us-east-1"
        encrypt      = true
        use_lockfile = true
      }
    }
</pre>

* DynamoDB locking (legacy, dynamoDB_locking):

<pre>
    terraform {
      backend "s3" {
        bucket         = "org-tf-state"
        key            = "platform/shared/backend.tfstate"
        region         = "us-east-1"
        encrypt        = true
        dynamodb_table = "terraform-locks"
      }
    }
</pre>

**Variables**
Common variables typically include:

* project_name: Name of the project used in bucket naming
* environment_name: Environment identifier (e.g., dev, prod) used in bucket naming
* owner: Owner identifier used in bucket naming
* region: AWS region where the bucket will be created (default: us-east-1)
* noncurrent_days: Number of days to retain noncurrent versions before deletion

The S3 bucket name is automatically generated using the pattern: `${project_name}-${environment_name}-${owner}-remote-backend`

**Security Features**
* Server-side encryption using AES256
* Complete public access blocking
* Versioning enabled by default
* Lifecycle policies for managing noncurrent versions
* Force destroy option for clean resource deletion

Refer to variables.tf for the complete list, defaults, and descriptions.