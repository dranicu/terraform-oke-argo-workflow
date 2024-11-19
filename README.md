# Terraform OKE with Argo Workflows

This repository contains Terraform code to deploy and configure an Argo Workflows environment on Oracle Cloud Infrastructure (OCI) using Oracle Kubernetes Engine (OKE). It simplifies the setup process for orchestrating Kubernetes-native workflows.

## Features
- Automated provisioning of OKE clusters.
- Deployment of Argo Workflows with necessary configurations.
- Integrated support for managing workflows via Kubernetes.
- Option to deploy via OCI Resource Manager for a streamlined experience.

## Prerequisites
- An Oracle Cloud Infrastructure account.
- Terraform CLI installed on your machine (for manual deployment).
- Properly configured OCI CLI for authentication.
- Kubernetes CLI (`kubectl`) installed.

## Installation

### Deploy using Terraform CLI

1. **Clone the repository**:
   ```bash
   git clone https://github.com/dranicu/terraform-oke-argo-workflow.git
   cd terraform-oke-argo-workflow
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Apply Terraform configuration**:
   ```bash
   terraform apply
   ```

   Confirm the changes to deploy the OKE cluster and Argo Workflows setup.


### Deploy using OCI Resource Manager

For a streamlined deployment, you can use Oracle Cloud Infrastructure’s Resource Manager:

1. Click the button below to deploy directly to OCI Resource Manager.

   [![Deploy to OCI](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/O_MT1bL_qgrimCxACnvTz0_1vx1P5vot6HzYzQzJxYlwcTtQTIJY8PrxzabRF7AS/n/ocisateam/b/code-zips/o/terraform-oke-argo-workflow-main.zip)

2. Sign in to your OCI account and follow the prompts to configure the stack.

3. Review the variables and submit the job to deploy the OKE cluster and Argo Workflows setup.

## Usage
- Submit and manage workflows through the Argo Workflows UI or CLI.
- For automation, integrate workflows with Kubernetes-native resources.

## Resources
- [Argo Workflows Documentation](https://argoproj.github.io/argo-workflows/)
- [Oracle Kubernetes Engine (OKE)](https://www.oracle.com/cloud-native/container-engine-kubernetes/)

## License
This project is open-source and distributed under the [MIT License](https://opensource.org/licenses/MIT).

