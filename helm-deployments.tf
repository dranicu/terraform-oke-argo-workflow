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

