output "vpc_id" {
  description = "ID de la VPC creada."
  value       = module.network.vpc_id
}

output "load_balancer_hostname" {
  description = "Hostname público del Load Balancer. Accede a la app por aquí."
  value       = module.loadbalancer.lb_hostname
}

output "vsi_private_ips" {
  description = "IPs privadas de las máquinas virtuales."
  value       = module.compute.private_ips
}

output "vsi_names" {
  description = "Nombres de las máquinas virtuales creadas."
  value       = module.compute.instance_names
}

output "backup_policy_id" {
  description = "ID de la política de backup aplicada a los volúmenes."
  value       = module.backup.backup_policy_id
}
