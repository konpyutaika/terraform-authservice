terraform {
  required_providers {
    kubernetes = {
      version = "2.11.0"
      source  = "hashicorp/kubernetes"
    }
    k8s = {
      version = "0.9.1"
      source  = "banzaicloud/k8s"
    }
  }
  required_version = ">= 0.14"
}