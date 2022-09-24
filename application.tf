resource "k8s_manifest" "application_crd" {
  content = templatefile("${path.module}/kubernetes/application.app.k8s.io_applications.yaml", {})
}