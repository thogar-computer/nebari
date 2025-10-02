resource "random_password" "root_password" {
  length  = 32
  special = false
}


resource "helm_release" "redis" {
  name      = "${var.name}-redis"
  namespace = var.namespace

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = "17.0.6"

  set {
    name  = "auth.password"
    value = random_password.root_password.result
  }

  values = concat([
    file("${path.module}/values.yaml"),
    jsonencode({
      # TODO: Remove hardcoded image values after Helm chart update
      # This is a workaround due to bitnami charts deprecation
      # See: https://github.com/bitnami/charts/issues/35164
      # See: https://github.com/nebari-dev/nebari/issues/3120
       image = {
        registry   = "docker.io"
        repository = "bitnamilegacy/redis"
        tag        = "7.0.4-debian-11-r4"
      }
      architecture = "standalone"
      master = {
        nodeSelector = {
          "${var.node-group.key}" = var.node-group.value
        }
      }
    })
  ], var.overrides)
}
