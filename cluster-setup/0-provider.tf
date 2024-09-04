provider "aws" {
  region = "us-east-2"
}


terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 3.4, <=3.32"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }

  backend "s3" {
    bucket = "microservices-demo-terraform-state"
    region = "us-east-2"
    key    = "microservices-demo/terraform.tfstate"
  }
}