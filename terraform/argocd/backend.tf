terraform {
  backend "s3" {
    bucket  = "mlops-tfstate-sergijrylskyj"
    key     = "argocd/terraform.tfstate"
    region  = "eu-north-1"
    profile = "sergijrylskyj"
  }
}
