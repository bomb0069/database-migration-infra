variable "name" {
  #  default     = ""
  type        = string
  description = "A name of terraform project"
}

variable "vpc_id" {
  #  default     = ""
  type        = string
  description = "id of VPC"
}

variable "region" {
  default     = "ap-southeast-1"
  type        = string
  description = "default region for GTP"
}

variable "environment" {
  default     = "dev"
  type        = string
  description = "A name of environment"
}

variable "app_version" {
  default     = "1.0.0"
  type        = string
  description = "version of backend"
}

variable "command_options" {
  default     = ""
  type        = string
  description = "command option to run schema migration"
}


variable "rollback_count" {
  default     = 1
  type        = number
  description = "number of changeset to rollback"
}
