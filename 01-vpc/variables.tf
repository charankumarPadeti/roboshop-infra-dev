variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "common_tags" {
  type = map 
  default = {
    Project_name = "Roboshop"
    Environment = "dev"
    Terraform = "True"
  }
}

variable "vpc_tags" {
  type = map 
  default = {}
}

variable "project_name" {
  type = string
  default = "roboshop"
}

variable "environment" {
  type = string
  default = "dev"
}

variable "public_subnet_cidr" {
  type = list 
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  type = list 
  default = ["10.0.11.0/24","10.0.12.0/24"]
}

variable "database_subnet_cidr" {
  type = list 
  default = ["10.0.21.0/24","10.0.22.0/24"]
}

variable "is_peering_required" {
  type = bool 
  default = true
}