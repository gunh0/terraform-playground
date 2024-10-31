module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  # Disable aws-auth configmap management
  manage_aws_auth_configmap = false

  # Enable cluster encryption using KMS
  cluster_encryption_config = {
    provider_key_arn = module.kms.key_arn
    resources        = ["secrets"]
  }

  # Node groups configuration
  eks_managed_node_groups = {
    critical = {
      name = "critical-workloads"

      instance_types = ["t3.xlarge"]
      capacity_type  = "ON_DEMAND"

      min_size     = 3
      max_size     = 4
      desired_size = 3

      update_config = {
        max_unavailable_percentage = 33
      }

      labels = {
        workload = "critical"
        type     = "on-demand"
      }

      taints = {
        dedicated = {
          key    = "workload"
          value  = "critical"
          effect = "NO_SCHEDULE"
        }
      }
    }

    general = {
      name = "general-workloads"

      instance_types = [
        "t3.xlarge",
        "t3a.xlarge",
        "r5.xlarge",
        "r5a.xlarge"
      ]

      capacity_type = "SPOT"

      min_size     = 2
      max_size     = 6
      desired_size = 3

      update_config = {
        max_unavailable_percentage = 50
      }

      labels = {
        workload = "general"
        type     = "spot"
      }
    }

    backup = {
      name = "backup-stable"

      instance_types = ["t3.xlarge"]
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      max_size     = 2
      desired_size = 1

      update_config = {
        max_unavailable_percentage = 100
      }

      labels = {
        workload = "backup"
        type     = "on-demand"
      }
    }
  }

  # Security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  # Enable CloudWatch logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Add necessary tags
  tags = {
    Environment = "demo"
    Terraform   = "true"
    Managed_by  = "terraform"
  }
}

# CloudWatch alarms for cluster monitoring
resource "aws_cloudwatch_metric_alarm" "cluster_nodes_cpu" {
  for_each = module.eks.eks_managed_node_groups

  alarm_name          = "${local.cluster_name}-${each.key}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "75"
  alarm_description   = "High CPU utilization for ${each.key} node group"
  alarm_actions       = [] # Add SNS topic ARN for notifications if needed

  dimensions = {
    AutoScalingGroupName = each.value.node_group_autoscaling_group_names[0]
  }
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  for_each = module.eks.eks_managed_node_groups

  name                   = "${local.cluster_name}-${each.key}-scale-up"
  autoscaling_group_name = each.value.node_group_autoscaling_group_names[0]
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

# Outputs
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}