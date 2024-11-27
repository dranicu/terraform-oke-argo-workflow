# List of all argo-workflow helm values https://github.com/argoproj/argo-helm/blob/main/charts/argo-workflows/values.yaml
crds:
  install: true

server:
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations:
      cert-manager.io/cluster-issuer: "le-clusterissuer"