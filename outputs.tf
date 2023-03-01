output "environment_url" {
  value = module.alb.lb_dns_name
}

output "alb_name" {
    value = module.alb.lb_arn
}