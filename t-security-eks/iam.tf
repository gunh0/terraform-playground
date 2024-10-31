# Cluster IAM role policies
resource "aws_iam_role_policy" "cluster_policy" {
  name = "${local.cluster_name}-cluster-policy"
  role = module.eks.cluster_iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "ec2:DescribeInstances",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications",
          "ec2:DescribeVpcs",
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Node groups IAM role policies
resource "aws_iam_role_policy" "node_groups_policy" {
  for_each = module.eks.eks_managed_node_groups
  name     = "${local.cluster_name}-${each.key}-node-policy"
  role     = each.value.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# KMS encryption policy
resource "aws_iam_role_policy" "cluster_encryption" {
  name = "${local.cluster_name}-cluster-encryption"
  role = module.eks.cluster_iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = [module.kms.key_arn]
      }
    ]
  })
}