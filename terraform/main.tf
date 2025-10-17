terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "hello-world-ml"
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "hello-world-ml"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = "hello-world-ml"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "hello-world-ml"
      }
    }

    template {
      metadata {
        labels = {
          app = "hello-world-ml"
        }
      }

      spec {
        container {
          name  = "hello-world-ml"
          image = "hello-world-ml:latest"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 8000
          }

          resources {
            requests = {
              memory = "128Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "256Mi"
              cpu    = "200m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "hello-world-ml-service"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = {
      app = "hello-world-ml"
    }

    port {
      port        = 8000
      target_port = 8000
    }

    type = "NodePort"
  }
}