variable "environment" {
  type        = string
  default     = "terraform"
  description = "Nome do ambiente"
}

variable "region_north_virginia" {
  type        = string
  default     = "us-east-1"
  description = "Nome do ambiente"
}

variable "region_north_virginia_az_a" {
  type        = string
  default     = "us-east-1a"
  description = "Nome do ambiente"
}

variable "region_north_virginia_az_b" {
  type        = string
  default     = "us-east-1b"
  description = "Nome do ambiente"
}

variable "vpc_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "CIDR da VPC"
}

variable "internet_gateway" {
  type        = string
  default     = "terraform-igw"
  description = "Internet Gateway da VPC"
}

variable "route_table_public" {
  type        = string
  default     = "terraform-public-route-table"
  description = "Internet Gateway da VPC"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "192.168.0.0/24"
  description = "Internet Gateway da VPC"
}

variable "public_subnet_name" {
  type        = string
  default     = "terraform-public-route-table"
  description = "Internet Gateway da VPC"
}