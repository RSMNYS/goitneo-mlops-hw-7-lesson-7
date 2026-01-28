variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "sergijrylskyj"
}

variable "aws_region" {
  description = "AWS region for AWS provider (має відповідати регіону EKS)"
  type        = string
  default     = "eu-north-1"
}

variable "eks_cluster_name" {
  description = "Назва існуючого EKS-кластера"
  type        = string
  default     = "goit-eks"
}

variable "eks_state_key" {
  description = "S3 key для remote state EKS"
  type        = string
  default     = "eks/terraform.tfstate"
}

variable "eks_state_region" {
  description = "Регіон бакета з remote state EKS"
  type        = string
  default     = "eu-north-1"
}

variable "eks_state_bucket" {
  description = "S3 bucket для remote state EKS"
  type        = string
  default     = "mlops-tfstate-sergijrylskyj"
}

variable "argocd_namespace" {
  description = "Namespace для ArgoCD"
  type        = string
  default     = "infra-tools"
}

variable "argocd_chart_version" {
  description = "Версія Helm-чарту ArgoCD"
  type        = string
  default     = "7.7.5"
}

variable "app_repo_url" {
  description = "Публічний Git-репозиторій з маніфестами"
  type        = string
  default     = "https://github.com/YOUR_GITHUB_USERNAME/goit-argo.git"
  # ⚠️ ВАЖЛИВО: Замініть YOUR_GITHUB_USERNAME на ваше реальне ім'я користувача GitHub
}

variable "app_repo_branch" {
  description = "Git гілка"
  type        = string
  default     = "main"
}