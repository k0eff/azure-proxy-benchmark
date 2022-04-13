resource "kubectl_manifest" "nginxTopologySpreadConstraints" {
  yaml_body = file("k8s-yaml/yaml/depl-nginx--TopologySpreadConstraints.yaml")
}
resource "kubectl_manifest" "nginxPodAntiAffinity" {
  yaml_body = file("k8s-yaml/yaml/depl-nginx-podAntiAffinity.yaml")
}
resource "kubectl_manifest" "nginxPodAffinityPriority" {
  yaml_body = file("k8s-yaml/yaml/depl-nginx-affinity-priority.yaml")
}
resource "kubectl_manifest" "priorityClassHigh" {
  yaml_body = file("k8s-yaml/yaml/prio-high.yaml")
}
resource "kubectl_manifest" "svcCiNginx" {
  yaml_body = file("k8s-yaml/yaml/svc-ci-nginx.yaml")
}