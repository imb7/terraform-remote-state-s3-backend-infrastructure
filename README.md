# Terraform Backend Infrastructure
This repository provisions a shared remote backend for Terraform projects on AWS. It focuses on creating a secure S3 bucket to hold Terraform state and, on the `dynamoDB_locking` branch, optionally provisioning a DynamoDB table used for legacy state locking.

## Overview

This project creates foundational backend resources used by downstream Terraform configurations: an S3 bucket for remote state with server-side encryption, versioning, lifecycle rules, and an optional DynamoDB table for state locks (on the `dynamoDB_locking` branch).

The preferred approach is S3 native locking (no DynamoDB table), but the `dynamoDB_locking` branch exists to support environments that still require or prefer DynamoDB-based locking and to provide a migration path.

## Branches

1. `main` — Uses S3 native locking (recommended). No DynamoDB table is provisioned by default.

2. `dynamoDB_locking` — Provides Terraform code and examples for provisioning a DynamoDB table used as a lock store for Terraform state. This branch was refactored for improved readability and modularity; check the branch files for modularized resources or modules that create the lock table.

## Architecture

* S3 state bucket: Private, versioned, and encrypted (SSE-S3 by default). The repository uses a variable-based bucket naming pattern to keep names unique per environment and owner.
* Locking:
    - Native S3 locking (`main`): uses `use_lockfile = true` in the S3 backend block — no extra AWS resources required.
    - DynamoDB locking (`dynamoDB_locking`): uses a DynamoDB table as a lock store. The branch contains the Terraform resources to create the table where needed.

## Prerequisites

* Terraform CLI: Use a recent Terraform version that supports S3 native locking (test with your CI/tooling; 1.3+ is a reasonable baseline).
* AWS credentials/role with permissions to create and manage the S3 bucket and (for the `dynamoDB_locking` branch) DynamoDB table. See the IAM section below for required permissions.

### IAM permissions (examples)

* S3-related: `s3:CreateBucket`, `s3:PutBucketVersioning`, `s3:PutEncryptionConfiguration`, `s3:PutBucketPolicy` (if used), `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`.
* DynamoDB (if using `dynamoDB_locking`): `dynamodb:CreateTable`, `dynamodb:DescribeTable`, `dynamodb:PutItem`, `dynamodb:GetItem`, `dynamodb:DeleteItem`, `dynamodb:UpdateItem`.

## Usage

1. Clone the repository and switch to the branch you want:

        git checkout main
        # or
        git checkout dynamoDB_locking

2. Configure variables

        Create or update `terraform.tfvars` with the required variables for the branch you are deploying. See `variables.tf` for exact names and defaults.

        The repository uses the following common variables (see `variables.tf` for full list and defaults):

        * `project_name` — name of the project used when constructing the S3 bucket name
        * `environment_name` — environment identifier (e.g., `dev`, `prod`)
        * `owner` — owner identifier used in bucket naming
        * `region` — AWS region where the bucket will be created (default: `us-east-1`)
        * `noncurrent_days` — days to retain noncurrent object versions before deletion

3. Deploy backend resources

        * Initialize:

                terraform init

        * Review:

                terraform plan -var-file=terraform.tfvars

        * Apply:

                terraform apply -var-file=terraform.tfvars

## DynamoDB locking branch notes

* The `dynamoDB_locking` branch contains the Terraform configuration to provision a DynamoDB table for Terraform state locking. Check the branch for resources named `aws_dynamodb_table` or modules that create the lock table.
* If you plan to use the DynamoDB table as the backend lock store for downstream Terraform projects, set `dynamodb_table` in the downstream backend configuration to the table name created by this repository.
* Example downstream backend snippet (set the `dynamodb_table` to the table name you created):

```hcl
terraform {
    backend "s3" {
        bucket         = "org-tf-state"
        key            = "platform/shared/backend.tfstate"
        region         = "us-east-1"
        encrypt        = true
        dynamodb_table = "terraform-locks" # point to the table created in this repo/branch
    }
}
```

## Backend configuration examples (S3 native locking)

Preferred (S3 native locking, `main`):

```hcl
terraform {
    backend "s3" {
        bucket       = "org-tf-state"
        key          = "platform/shared/backend.tfstate"
        region       = "us-east-1"
        encrypt      = true
        use_lockfile = true
    }
}
```

## Notes and best practices

* Prefer S3 native locking for new projects unless you have a specific need for DynamoDB-based locking (legacy tooling, compliance, etc.).
* When using the `dynamoDB_locking` branch, ensure you have the DynamoDB IAM permissions noted above and that the downstream projects reference the same `dynamodb_table` name.
* The branch has been refactored to improve readability and modularity; if you consume modules from this repository, check module inputs and outputs for any naming changes.

Refer to the repository files (especially `variables.tf`) for the authoritative list of variables, defaults, and descriptions.