# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Create an EKS Cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = aws_subnet.private_subnets[*].id
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
  ]
}

# Create IAM Role for EKS Cluster
# ... (IAM role and policy attachments omitted for brevity)

# Create Private Subnets for the EKS Cluster
resource "aws_subnet" "private_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    "Name" = "private-subnet-${count.index + 1}"
  }
}

# Add tags to the private subnets
resource "aws_ec2_tag" "subnet_tags" {
  count       = length(aws_subnet.private_subnets)
  resource_id = aws_subnet.private_subnets[count.index].id

  key   = "kubernetes.io/cluster/${aws_eks_cluster.my_cluster.name}"
  value = "shared"
}

resource "aws_ec2_tag" "subnet_elb_tag" {
  count       = length(aws_subnet.private_subnets)
  resource_id = aws_subnet.private_subnets[count.index].id

  key   = "kubernetes.io/role/internal-elb"
  value = "1"
}

# Create VPC for the EKS Cluster
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-eks-vpc"
  }
}

# Fetch available Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}