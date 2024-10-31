# terraform-playground

### Overview

This repository serves as a playground for experimenting with Terraform.

<br/>

### t-security-eks

> [t-security-eks](./t-security-eks/README.md) is a Terraform project that demonstrates a secure and efficient architecture for deploying an EKS cluster on AWS.

The T Security Demo architecture builds a cloud-based environment on AWS utilizing EKS (Elastic Kubernetes Service), focusing on security and efficiency. The main components are as follows:

- VPC: A Virtual Private Cloud for secure resource management with public and private subnets.
- EKS Cluster: Manages containerized applications and supports cluster encryption using KMS.
- Node Groups:
- Critical Node Group: On-demand instances for important workloads.
- General Node Group: Spot instances for cost efficiency.
- Backup Node Group: On-demand instances for reliable backups.
- CloudWatch: Manages performance through log collection and monitoring of the cluster.
- IAM: Handles access control and permissions management.

This architecture is designed to consider both security and performance simultaneously.
