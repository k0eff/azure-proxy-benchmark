resource "kubectl_manifest" "nginxCfgMap" {
  yaml_body = file("k8s-yaml/yaml/cfg-nginx.yaml")
}
resource "kubectl_manifest" "nginxDepl" {
  yaml_body = file("k8s-yaml/yaml/depl-nginx.yaml")
}
resource "kubectl_manifest" "nginxSvc" {
  yaml_body = file("k8s-yaml/yaml/svc-nginx.yaml")
}
resource "kubectl_manifest" "apacheDepl" {
  yaml_body = file("k8s-yaml/yaml/depl-apache.yaml")
}
resource "kubectl_manifest" "apacheSvc" {
  yaml_body = file("k8s-yaml/yaml/svc-apache.yaml")
}