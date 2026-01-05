output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "ecr_repository_home_url" {
  value = aws_ecr_repository.home-helm.repository_url
}

output "ecr_repository_profile_url" {
  value = aws_ecr_repository.profile-helm.repository_url
}