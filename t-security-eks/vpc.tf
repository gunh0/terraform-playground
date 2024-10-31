module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0" # Specify VPC module version

  name = "${local.cluster_name}-vpc"
  cidr = "10.0.0.0/20" # Allocate 4,096 IP addresses

  azs             = ["${local.region}a", "${local.region}c"]
  private_subnets = ["10.0.0.0/23", "10.0.2.0/23"] # 512 IPs per subnet
  public_subnets  = ["10.0.4.0/23", "10.0.6.0/23"] # 512 IPs per subnet

  enable_nat_gateway = true
  single_nat_gateway = true

  # Optional: Enable VPC Flow Logs for network traffic monitoring
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = {
    Environment = "demo"
    Terraform   = "true"
  }
}