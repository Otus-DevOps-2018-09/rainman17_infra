output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}

#output "app_loadbalancer_ip" {
#  value = "${google_compute_forwarding_rule.reddit-app-lb.ip_address}"
#}
