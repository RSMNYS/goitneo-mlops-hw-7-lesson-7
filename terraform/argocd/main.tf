# Namespace для ArgoCD
resource "kubernetes_namespace" "argo" {
  metadata {
    name = var.argocd_namespace
  }
}

# Встановлення ArgoCD через офіційний Helm-чарт
resource "helm_release" "argo" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argo.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  recreate_pods = true
  replace       = true

  values = [file("${path.module}/values/argocd-values.yaml")]

  depends_on = [
    kubernetes_namespace.argo
  ]
}

# ApplicationSet буде створено через kubectl після встановлення ArgoCD
# Дивіться applicationset.yaml для маніфесту
