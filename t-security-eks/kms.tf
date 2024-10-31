module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.0"

  description = "EKS Secret Encryption Key"
  key_usage   = "ENCRYPT_DECRYPT"

  # Key policies
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_users = [
    module.eks.cluster_iam_role_arn
  ]

  aliases = ["eks/${local.cluster_name}"]

  tags = {
    Environment = "demo"
  }
}

data "aws_caller_identity" "current" {}