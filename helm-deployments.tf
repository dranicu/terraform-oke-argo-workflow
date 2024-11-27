# Copyright (c) 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

locals {
  deploy_from_operator = var.create_operator_and_bastion
  deploy_from_local    = alltrue([!local.deploy_from_operator, var.control_plane_is_public])
}

data "oci_containerengine_cluster_kube_config" "kube_config" {
  count = local.deploy_from_local ? 1 : 0

  cluster_id = module.oke.cluster_id
  endpoint   = "PUBLIC_ENDPOINT"
}

module "argo-workflows" {
  count  = var.deploy_argo_workflows ? 1 : 0
  source = "./helm-module"

  bastion_host    = module.oke.bastion_public_ip
  bastion_user    = var.bastion_user
  operator_host   = module.oke.operator_private_ip
  operator_user   = var.bastion_user
  ssh_private_key = tls_private_key.stack_key.private_key_openssh

  deploy_from_operator = local.deploy_from_operator
  deploy_from_local    = local.deploy_from_local

  deployment_name     = "argo-workflows"
  helm_chart_name     = "argo-workflows"
  namespace           = "argo-workflows"
  helm_repository_url = "https://argoproj.github.io/argo-helm"

  pre_deployment_commands = [
  "curl -sLO \"https://github.com/argoproj/argo-workflows/releases/download/v3.6.0-rc4/argo-linux-amd64.gz\"",
  "gunzip \"argo-linux-amd64.gz\"",
  "chmod +x \"argo-linux-amd64\"",
  "sudo mv \"./argo-linux-amd64\" /usr/local/bin/argo",
  ]
  post_deployment_commands = ["kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default"]

  helm_template_values_override = templatefile(
    "${path.root}/helm-values-templates/argo-workflows-values.yaml.tpl",
    {}
  )
  helm_user_values_override = try(base64decode(var.argo_workflows_user_values_override), var.argo_workflows_user_values_override)

  kube_config = one(data.oci_containerengine_cluster_kube_config.kube_config.*.content)

  depends_on = [module.oke]
}

module "nginx" {
  count  = var.deploy_nginx ? 1 : 0
  source = "./helm-module"

  bastion_host    = module.oke.bastion_public_ip
  bastion_user    = var.bastion_user
  operator_host   = module.oke.operator_private_ip
  operator_user   = var.bastion_user
  ssh_private_key = tls_private_key.stack_key.private_key_openssh

  deploy_from_operator = local.deploy_from_operator
  deploy_from_local    = local.deploy_from_local

  deployment_name     = "ingress-nginx"
  helm_chart_name     = "ingress-nginx"
  namespace           = "nginx"
  helm_repository_url = "https://kubernetes.github.io/ingress-nginx"

  pre_deployment_commands  = []
  post_deployment_commands = []

  helm_template_values_override = templatefile(
    "${path.root}/helm-values-templates/nginx-values.yaml.tpl",
    {
      min_bw        = 100,
      max_bw        = 100,
      pub_lb_nsg_id = module.oke.pub_lb_nsg_id
      state_id      = local.state_id
    }
  )
  helm_user_values_override = try(base64decode(var.nginx_user_values_override), var.nginx_user_values_override)

  kube_config = one(data.oci_containerengine_cluster_kube_config.kube_config.*.content)
  depends_on  = [module.oke]
}

module "cert-manager" {
  count  = var.deploy_cert_manager ? 1 : 0
  source = "./helm-module"

  bastion_host    = module.oke.bastion_public_ip
  bastion_user    = var.bastion_user
  operator_host   = module.oke.operator_private_ip
  operator_user   = var.bastion_user
  ssh_private_key = tls_private_key.stack_key.private_key_openssh

  deploy_from_operator = local.deploy_from_operator
  deploy_from_local    = local.deploy_from_local

  deployment_name     = "cert-manager"
  helm_chart_name     = "cert-manager"
  namespace           = "cert-manager"
  helm_repository_url = "https://charts.jetstack.io"

  pre_deployment_commands = []
  post_deployment_commands = [
    "cat <<'EOF' | kubectl apply -f -",
    "apiVersion: cert-manager.io/v1",
    "kind: ClusterIssuer",
    "metadata:",
    "  name: le-clusterissuer",
    "spec:",
    "  acme:",
    "    # You must replace this email address with your own.",
    "    # Let's Encrypt will use this to contact you about expiring",
    "    # certificates, and issues related to your account.",
    "    email: user@oracle.om",
    "    server: https://acme-staging-v02.api.letsencrypt.org/directory",
    "    privateKeySecretRef:",
    "      # Secret resource that will be used to store the account's private key.",
    "      name: le-clusterissuer-secret",
    "    # Add a single challenge solver, HTTP01 using nginx",
    "    solvers:",
    "    - http01:",
    "        ingress:",
    "          ingressClassName: nginx",
    "EOF"
  ]

  helm_template_values_override = templatefile(
    "${path.root}/helm-values-templates/cert-manager-values.yaml.tpl",
    {}
  )
  helm_user_values_override = try(base64decode(var.cert_manager_user_values_override), var.cert_manager_user_values_override)

  kube_config = one(data.oci_containerengine_cluster_kube_config.kube_config.*.content)

  depends_on = [module.oke]
}
