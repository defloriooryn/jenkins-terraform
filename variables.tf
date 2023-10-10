variable "region" {
  type    = string
  default = "us-east-1"
}

# VPC & Subnet 
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_public" {
  type = any
  default = {
    "public-1" = { cidr = "10.0.0.0/24", az = "us-east-1a" }
    "public-2" = { cidr = "10.0.1.0/24", az = "us-east-1b" }
  }
}

variable "subnet_private" {
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "private-1" = { cidr = "10.0.2.0/24", az = "us-east-1a" }
    "private-2" = { cidr = "10.0.3.0/24", az = "us-east-1b" }
  }
}

variable "subnet_database" {
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "private-3" = { cidr = "10.0.4.0/24", az = "us-east-1a" }
    "private-4" = { cidr = "10.0.5.0/24", az = "us-east-1b" }
  }
}

# Security Group
variable "sg_alb_port" {
  type    = list(any)
  default = [80, 443]
}

variable "sg_ec2_port" {
  type    = list(any)
  default = [80, 22]
}

variable "sg_rds_port" {
  type    = number
  default = 3306
}

# Auto Scalling Group
variable "instance_template" {
  type = map(string)
  default = {
    type = "t2.micro"
    ami  = "ami-067d1e60475437da2" #Amazon Linux 2023
  }
}

# ASG
variable "asg" {
  type = any
  default = {
    az      = ["us-east-1a", "us-east-1b"]
    desired = 2
    min     = 2
    max     = 4
  }
}

# Database
variable "db" {
  type = map(string)
  default = {
    allocated_storage    = 10
    db_name              = "mydb"
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class       = "db.t3.micro"
    username             = "admin"
    password             = "admin"
    parameter_group_name = "default.mysql5.7"
    skip_final_snapshot  = true
    availability_zone    = "us-east-1a"
    multi_az             = false
  }
}