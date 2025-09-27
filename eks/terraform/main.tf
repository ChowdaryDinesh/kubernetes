
data "aws_availability_zones" "available" {}

module "myapp-vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.1.1"

    name = "myapp-vpc"
    cidr = var.vpc_cidr
    private_subnets = local.private_subnets
    public_subnets = local.public_subnets
    azs = data.aws_availability_zones.available.names 
    
    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true

    tags = {
        "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
    }

    public_subnet_tags = {
        "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
        "kubernetes.io/role/elb" = 1 
    }

    private_subnet_tags = {
        "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
        "kubernetes.io/role/internal-elb" = 1 
    }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name = var.k8s_cluster_name
  cluster_version = var.k8s_version

  subnet_ids = module.myapp-vpc.private_subnets
  vpc_id = module.myapp-vpc.vpc_id

  # to access cluster externally with kubectl
  cluster_endpoint_public_access = true
  enable_irsa = true
  node_security_group_additional_rules = {                                                                  
    all_ingress = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    environment = "development"
    application = "myapp"
  }

  eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3
      # disk_type = "gp3" # set this for faster deployment of ebs addon, this is default recommended from aws
      instance_types = ["t2.small"]

      # add permission for ebs storage creation for Consul
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      } 
    }
  }
}

# enable ebs-csi driver add-on for ebs storage creation for Consul
resource "aws_eks_addon" "ebs" {
  cluster_name      = module.eks.cluster_name
  addon_name        = "aws-ebs-csi-driver"
}



resource "aws_iam_role" "ebs_csi_irsa" {
  name = "${module.eks.cluster_name}-ebs-csi-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks.cluster_oidc_issuer_url}:aud" = "sts.amazonaws.com"
            "${module.eks.cluster_oidc_issuer_url}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ebs_csi_attach" {
  role       = aws_iam_role.ebs_csi_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}