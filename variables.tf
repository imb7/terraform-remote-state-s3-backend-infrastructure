########################
### For providers.tf ###
########################
variable "region" {
  description = "Name of region where bucket for remote state will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "value"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
}

variable "environment_name" {
  description = "Name of the environment (e.g., dev, prod)"
  type        = string
}


###################
### For main.tf ###
###################

variable "noncurrent_days" {
  description = "Number of days to retain noncurrent versions of objects in the remote state bucket"
  type        = number
}