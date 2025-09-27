locals {

  # Generate total subnets (6: 3 public + 3 private)

  total_subnets = [

    for i in range(var.subnet_count * 2) :

    cidrsubnet(var.vpc_cidr, 8, i)

  ]
 
  public_subnets  = slice(local.total_subnets, 0, var.subnet_count)

  private_subnets = slice(local.total_subnets, var.subnet_count, var.subnet_count * 2)

}

 