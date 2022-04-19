/**
  These are the apache resources - which serves as a static http server (simulating an api endpoint). Using Apache in order to avoid ambiguity with two nginx-es.
*/
resource "kubectl_manifest" "apacheDepl" {
  yaml_body = file("k8s-yaml/yaml/depl-apache.yaml")
}
resource "kubectl_manifest" "apacheSvc" {
  yaml_body = file("k8s-yaml/yaml/svc-apache.yaml")
}

/**
  This is Nginx serving as a reverse proxy, pointing to the Apache static server
*/
resource "kubectl_manifest" "nginxCfgMap" {
  yaml_body = file("k8s-yaml/yaml/cfg-nginx.yaml")
}
resource "kubectl_manifest" "nginxDepl" {
  yaml_body = file("k8s-yaml/yaml/depl-nginx.yaml")
}
resource "kubectl_manifest" "nginxSvc" {
  yaml_body = file("k8s-yaml/yaml/svc-nginx.yaml")
}


/**
  This is Envoy serving as a reverse proxy, pointing to the Apache static server
*/
resource "kubectl_manifest" "envoyCfgMap" {
  yaml_body = file("k8s-yaml/yaml/cfg-envoy.yaml")
}
resource "kubectl_manifest" "envoyDepl" {
  yaml_body = file("k8s-yaml/yaml/depl-envoy.yaml")
}
resource "kubectl_manifest" "envoySvc" {
  yaml_body = file("k8s-yaml/yaml/svc-envoy.yaml")
}
