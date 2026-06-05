variable "prefix" {
  type        = string
  description = "Prefijo para nombrar recursos."
}

variable "resource_group_id" {
  type        = string
  description = "ID del resource group."
}

variable "subnet_ids" {
  type        = list(string)
  description = "IDs de las subnets donde vive el balanceador."
}

variable "vpc_id" {
  type        = string
  description = "ID de la VPC, necesario para el security group del balanceador."
}

variable "member_ips" {
  type        = list(string)
  description = "IPs privadas de las VSI que recibirán tráfico."
}

# Security group propio del balanceador: permite HTTP entrante desde internet
resource "ibm_is_security_group" "lb_sg" {
  name           = "${var.prefix}-lb-sg"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
}

resource "ibm_is_security_group_rule" "lb_ingress_http" {
  group     = ibm_is_security_group.lb_sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "lb_egress_all" {
  group     = ibm_is_security_group.lb_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Application Load Balancer público
resource "ibm_is_lb" "alb" {
  name            = "${var.prefix}-alb"
  subnets         = var.subnet_ids
  type            = "public"
  resource_group  = var.resource_group_id
  security_groups = [ibm_is_security_group.lb_sg.id]
}

# Pool de backend con health check HTTP
resource "ibm_is_lb_pool" "pool" {
  name           = "${var.prefix}-pool"
  lb             = ibm_is_lb.alb.id
  algorithm      = "round_robin"
  protocol       = "http"
  health_delay   = 5
  health_retries = 2
  health_timeout = 2
  health_type    = "http"
  health_monitor_url = "/"
}

# Miembros del pool: las dos VSI escuchando en el puerto 80
resource "ibm_is_lb_pool_member" "members" {
  count          = length(var.member_ips)
  lb             = ibm_is_lb.alb.id
  pool           = ibm_is_lb_pool.pool.pool_id
  port           = 80
  target_address = var.member_ips[count.index]
}

# Listener que recibe tráfico HTTP en el puerto 80
resource "ibm_is_lb_listener" "listener" {
  lb           = ibm_is_lb.alb.id
  port         = 80
  protocol     = "http"
  default_pool = ibm_is_lb_pool.pool.pool_id
}

output "lb_hostname" {
  value = ibm_is_lb.alb.hostname
}

output "lb_id" {
  value = ibm_is_lb.alb.id
}
