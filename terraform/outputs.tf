output "service_name" {
  value = kubernetes_service.app.metadata[0].name
}

output "namespace" {
  value = kubernetes_namespace.app.metadata[0].name
}