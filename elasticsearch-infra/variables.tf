# VPC Configuration
variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "aws_vpc" {
  default = "my-elasticsearch-vpc"
}

# Subnets Configuration
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
}

# Tags for Resources
variable "tags" {
  type    = map(string)
  default = {}
}

# EC2 Instance Configuration
variable "ami_id" {
  default = "ami-04a92520784b93e73" # Adjust as needed
}

variable "instance_type" {
  default = "t3.medium"  # Suitable for Elasticsearch
}

variable "subnet_id" {
  default = "public"  # Using public subnets for now
}

variable "key_name" {
  default = "infra_key"
}

variable "security_group_name" {
  default = "elasticsearch-SG"
}

# Security Group Configuration
variable "ingress_ports" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 9200
      to_port     = 9200
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs, adjust for security
    },
    {
      from_port   = 9300
      to_port     = 9300
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  # For Elasticsearch cluster node communication
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  # For SSH access
    }
  ]
}

variable "egress_ports" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# Autoscaling Configuration (Optional for clustering)
variable "desired_capacity" {
  default = "1"  # Single node Elasticsearch setup
}

variable "max_size" {
  default = "3"
}

variable "min_size" {
  default = "1"
}

# Elasticsearch Port
variable "port" {
  default = "9200"  # Default Elasticsearch port
}

variable "listener_port" {
  default = "9200"  # Listener port for Elasticsearch
}
