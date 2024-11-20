module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "1.17.0" 
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

