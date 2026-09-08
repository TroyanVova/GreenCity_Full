variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short name used to prefix/tag all resources."
  type        = string
  default     = "greencity"
}

variable "environment" {
  description = "Environment tag (e.g. demo, dev, staging)."
  type        = string
  default     = "demo"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets, one per AZ."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "AZs to spread the public subnets across. Must match the length of public_subnet_cidrs."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ssh_allowed_cidr" {
  description = "CIDR blocks allowed to SSH (port 22) into instances."
  type        = list(string)
}

variable "app_ingress_port" {
  description = "HTTP port the frontend/app is served on (Nginx)."
  type        = number
  default     = 80
}

variable "db_port" {
  description = "Postgres port, only reachable from the app security group, never from the internet."
  type        = number
  default     = 5432
}

variable "instance_type" {
  description = "EC2 instance type for the single app host."
  type        = string
  default     = "t3.small"
}

variable "ec2_key_name" {
  description = "Existing EC2 key pair name for SSH fallback access. Leave empty to launch without a key pair — SSM Run Command doesn't need one."
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Postgres database name."
  type        = string
  default     = "greencity"
}

variable "db_username" {
  description = "Postgres master username."
  type        = string
  default     = "greencity_admin"
}

variable "db_password" {
  description = "Postgres master password. Set this in terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS storage in GB ."
  type        = number
  default     = 20
}
