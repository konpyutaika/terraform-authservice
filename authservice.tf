locals {
  oidc_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
    //TODO: change
    "app.kubernetes.io/part-of"    = "flowmanager"
    "app.kubernetes.io/component"  = "oidc-authservice"
    "app.kubernetes.io/name"       = "oidc-authservice"
    "app.kubernetes.io/instance"   = "oidc-authservice-v1.0.0"
    "app.kubernetes.io/version"    = "v1.0.0"
  }
}

resource "kubernetes_secret" "oidc_authservice_parameters" {
  metadata {
    name      = "oidc-authservice-parameters"
    namespace = var.namespace
    labels    = local.oidc_labels
  }

  data = {
    application_secret  = var.authservice["client_secret"]
    client_id           = var.authservice["client_id"]
    namespace           = var.namespace
    oidc_auth_url       = var.authservice["auth_url"]
    oidc_provider       = var.authservice["issuer"]
    oidc_redirect_url   = var.authservice["redirect_url"]
    skip_auth_uri       = "/dex/ /.well-known/"
    userid-header       = var.userid_header
    userid-header-token = "${var.userid_header}-token"
    userid-prefix       = ""
    userid-claim        = var.authservice["userid_claim"]
    oidc_scopes         = var.authservice["scopes"]
  }
}

resource "kubernetes_service" "authservice" {
  metadata {
    name      = "authservice"
    namespace = var.namespace

    labels = local.oidc_labels
  }

  spec {
    port {
      name        = "http-authservice"
      port        = 8080
      target_port = "http-api"
    }

    selector = merge(
    local.oidc_labels, { app = "authservice" }
    )

    type                        = "ClusterIP"
    publish_not_ready_addresses = true
  }
}

resource "kubernetes_stateful_set" "authservice" {
  depends_on = [k8s_manifest.oidc_authservice]
  metadata {
    name      = "authservice"
    namespace = var.namespace

    labels = local.oidc_labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = merge(
      local.oidc_labels, { app = "authservice" }
      )
    }

    template {
      metadata {
        labels = merge(
        local.oidc_labels, { app = "authservice" }
        )

        annotations = {
          "sidecar.istio.io/inject" = "false"
        }
      }

      spec {
        automount_service_account_token = true
        container {
          name  = "authservice"
          image = "gcr.io/arrikto/kubeflow/oidc-authservice:28c59ef"

          port {
            name           = "http-api"
            container_port = 8080
          }

          env {
            name = "USERID_HEADER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.oidc_authservice_parameters.metadata.0.name
                key  = "userid-header"
              }
            }
          }

          env {
            name = "USERID_TOKEN_HEADER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.oidc_authservice_parameters.metadata.0.name
                key  = "userid-header-token"
              }
            }
          }

          env {
            name = "USERID_PREFIX"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.oidc_authservice_parameters.metadata.0.name
                key  = "userid-prefix"
              }
            }
          }

          env {
            name = "USERID_CLAIM"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.oidc_authservice_parameters.metadata.0.name
                key  = "userid-claim"
              }
            }
          }

          env {
            name = "OIDC_PROVIDER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.oidc_authservice_parameters.metadata.0.name
                key  = "oidc_provider"
              }
            }
          }

          env {
            name = "OIDC_AUTH_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.oidc_authservice_parameters.metadata.0.name
                key  = "oidc_auth_url"
              }
            }
          }

          env {
            name = "OIDC_SCOPES"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.oidc_authservice_parameters.metadata.0.name
                key  = "oidc_scopes"
              }
            }
          }

          env {
            name = "REDIRECT_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.oidc_authservice_parameters.metadata.0.name
                key  = "oidc_redirect_url"
              }
            }
          }

          env {
            name = "SKIP_AUTH_URI"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.oidc_authservice_parameters.metadata.0.name
                key  = "skip_auth_uri"
              }
            }
          }

          env {
            name  = "PORT"
            value = "8080"
          }

          env {
            name = "CLIENT_ID"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.oidc_authservice_parameters.metadata.0.name
                key  = "client_id"
              }
            }
          }

          env {
            name = "CLIENT_SECRET"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.oidc_authservice_parameters.metadata.0.name
                key  = "application_secret"
              }
            }
          }

          env {
            name  = "STORE_PATH"
            value = "/var/lib/authservice/data.db"
          }

          volume_mount {
            name       = "authservice"
            mount_path = "/var/lib/authservice"
          }

          readiness_probe {
            http_get {
              path = "/"
              port = "8081"
            }
          }

          image_pull_policy = "Always"
        }

        security_context {
          fs_group = 111
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"
    }

    volume_claim_template {
      metadata {
        name      = "authservice"
        namespace = var.namespace
        labels = merge(
        local.oidc_labels, { app = "authservice" }
        )
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
    service_name = "authservice"
  }
}

locals {
  oidc_authservice_manifests = split(
  "\n---\n",
  templatefile(
    "${path.module}/kubernetes/oidc-authservice.yaml",
    {
      namespace     = var.namespace
      labels        = local.oidc_labels
      userid-header = var.userid_header
    })
  )
}

resource "k8s_manifest" "oidc_authservice" {
  depends_on = [k8s_manifest.application_crd]
  count      = length(local.oidc_authservice_manifests)
  content    = local.oidc_authservice_manifests[count.index]
}