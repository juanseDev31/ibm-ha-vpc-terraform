variable "prefix" {
  type        = string
  description = "Prefijo para nombrar recursos."
}

variable "resource_group_id" {
  type        = string
  description = "ID del resource group."
}

variable "vpc_id" {
  type        = string
  description = "ID de la VPC."
}

variable "vsi_profile" {
  type        = string
  description = "Perfil de las máquinas virtuales."
}

variable "image_id" {
  type        = string
  description = "ID de la imagen del SO."
}

variable "ssh_key_id" {
  type        = string
  description = "ID de la SSH key."
}

variable "security_group_id" {
  type        = string
  description = "ID del security group."
}

variable "instances" {
  description = "Lista de instancias a crear con su subnet y zona."
  type = list(object({
    name      = string
    subnet_id = string
    zone      = string
  }))
}

variable "backup_tag" {
  type        = string
  description = "User tag para que la política de backup respalde el volumen de arranque."
}

# Script cloud-init: instala Nginx y muestra el hostname para ver el balanceo
locals {
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    echo "<h1>Servidor: $(hostname)</h1><p>Alta disponibilidad con IBM Cloud VPC + Terraform</p>" > /var/www/html/index.html
    systemctl enable nginx
    systemctl restart nginx
  EOF
}

# Crea una VSI por cada entrada en la lista "instances"
resource "ibm_is_instance" "vsi" {
  for_each = { for inst in var.instances : inst.name => inst }

  name           = "${var.prefix}-${each.value.name}"
  vpc            = var.vpc_id
  zone           = each.value.zone
  profile        = var.vsi_profile
  image          = var.image_id
  keys           = [var.ssh_key_id]
  resource_group = var.resource_group_id
  user_data      = local.user_data

  primary_network_interface {
    subnet          = each.value.subnet_id
    security_groups = [var.security_group_id]
  }

  # El user tag en el boot volume hace que la política de backup lo respalde
  boot_volume {
    tags = [var.backup_tag]
  }
}

output "private_ips" {
  value = [for vsi in ibm_is_instance.vsi : vsi.primary_network_interface[0].primary_ip[0].address]
}

output "instance_names" {
  value = [for vsi in ibm_is_instance.vsi : vsi.name]
}

output "instance_ids" {
  value = [for vsi in ibm_is_instance.vsi : vsi.id]
}
