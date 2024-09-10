# module "kubernetes_addons" {
#   source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.25.0"

#   eks_cluster_id = module.eks_blueprints.eks_cluster_id

#   # EKS Add-ons
#   enable_amazon_eks_aws_ebs_csi_driver = true

#   # Self-managed Add-ons
#   enable_aws_efs_csi_driver = true

#   # Optional aws_efs_csi_driver_helm_config
#   aws_efs_csi_driver_helm_config = {
#     repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
#     version    = "2.4.0"
#     namespace  = "kube-system"
#   }

#   enable_aws_load_balancer_controller = true

#   enable_metrics_server = true
#   enable_cert_manager   = true

#   # enable_cluster_autoscaler = true

#   enable_karpenter = true
#   karpenter_helm_config = {
#     name       = "karpenter"
#     chart      = "karpenter"
#     repository = "oci://public.ecr.aws/karpenter"
#     version    = "v0.27.0"
#     namespace  = "karpenter"
#   }
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.eks_blueprints.eks_cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       args        = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
#     }
#   }
# }




module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "1.16.0" 
  cluster_name      = "microservices-demo"
  cluster_endpoint  = module.eks_blueprints.eks_cluster_endpoint
  cluster_version   = module.eks_blueprints.eks_cluster_version
  oidc_provider_arn = module.eks_blueprints.eks_oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    # coredns = {
    #   most_recent = true
    # }
    # vpc-cni = {
    #   most_recent = true
    # }
    # kube-proxy = {
    #   most_recent = true
    # }
  }

  enable_aws_load_balancer_controller    = true
  enable_cluster_autoscaler              = true
  enable_aws_efs_csi_driver              = true
  # enable_karpenter                       = true
  # enable_kube_prometheus_stack           = true
  enable_metrics_server                  = true
  enable_external_dns                    = true
  enable_cert_manager                    = true
  # cert_manager_route53_hosted_zone_arns  = ["arn:aws:route53:::hostedzone/XXXXXXXXXXXXX"]

  tags = {
    Environment = "dev"
  }
}


