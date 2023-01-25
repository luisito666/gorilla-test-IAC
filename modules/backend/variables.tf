variable "region" {
  description = "AWS region to deploy"
}

variable "subnet_cidr_block" {
  description = "CIDR block to use for subnet"
}

variable "cluster_name" {
  default = "main_cluster"
  type    = string
}

variable "ecr_name" {
  default = "timeoff-registry"
  type = string
}
