variable vpc_cidr {
    description = "VPC cide block"
    default = "172.60.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets for each type (public/private)"
  type        = number
  default     = 3
}

variable k8s_version {
    default = "1.32"
}

variable k8s_cluster_name {
    default = "myapp-eks-cluster"
    type = "string"
}

variable aws_region {
    default = "eu-central-1"
    type = "string"
}