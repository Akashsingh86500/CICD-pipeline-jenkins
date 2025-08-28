data "aws_caller_identity" "current" {}
locals { tags = { Project = "microservices-cicd" } }
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = local.tags
}
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags                    = local.tags
}
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags                    = local.tags
}
resource "aws_internet_gateway" "igw" { vpc_id = aws_vpc.main.id tags = local.tags }
resource "aws_route_table" "public" { vpc_id = aws_vpc.main.id tags = local.tags }
resource "aws_route" "public_inet" { route_table_id = aws_route_table.public.id destination_cidr_block = "0.0.0.0/0" gateway_id = aws_internet_gateway.igw.id }
resource "aws_route_table_association" "a" { subnet_id = aws_subnet.public_a.id route_table_id = aws_route_table.public.id }
resource "aws_route_table_association" "b" { subnet_id = aws_subnet.public_b.id route_table_id = aws_route_table.public.id }
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"
  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  subnet_ids      = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  vpc_id          = aws_vpc.main.id
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      instance_types = ["t3.small"]
    }
  }
  tags = local.tags
}
resource "aws_ecr_repository" "repos" {
  for_each = toset(var.ecr_repos)
  name     = each.value
  image_scanning_configuration { scan_on_push = true }
  tags = local.tags
}
output "ecr_uri_base" { value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com" }
output "cluster_name" { value = var.cluster_name }
output "region" { value = var.region }
