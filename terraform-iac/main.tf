resource "aws_ecr_repository" "home-helm" {
  name                 = "home-helm"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "home_cleanup" {
  repository = aws_ecr_repository.home-helm.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_repository" "profile-helm" {
  name                 = "profile-helm"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "profile_cleanup" {
  repository = aws_ecr_repository.profile-helm.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}



resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = data.aws_subnets.eks.ids
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}

resource "aws_eks_node_group" "batman_nodes" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "batman-ng"
  node_role_arn  = aws_iam_role.eks_node_role.arn
  subnet_ids     = data.aws_subnets.eks.ids

  instance_types = ["t3.small"]   
  disk_size      = 20

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  capacity_type = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.node_policies
  ]
}