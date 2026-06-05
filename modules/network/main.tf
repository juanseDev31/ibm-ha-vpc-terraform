variable "prefix" {
  type        = string
  description = "Prefijo para nombrar recursos."
}

variable "resource_group_id" {
  type        = string
  description = "ID del resource group."
}

variable "zone_1" {
  type        = string
  description = "Primera zona de disponibilidad."
}

variable "zone_2" {
  type        = string
  description = "Segunda zona de disponibilidad."
}

# VPC principal
resource "ibm_is_vpc" "vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = var.resource_group_id
}

# Public Gateways: permiten que las VSI accedan a internet (ej. updates apt)
resource "ibm_is_public_gateway" "gw_1" {
  name           = "${var.prefix}-gw-1"
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zone_1
  resource_group = var.resource_group_id
}

resource "ibm_is_public_gateway" "gw_2" {
  name           = "${var.prefix}-gw-2"
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zone_2
  resource_group = var.resource_group_id
}

# Subnet 1 en la zona 1
resource "ibm_is_subnet" "subnet_1" {
  name                     = "${var.prefix}-subnet-1"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = var.zone_1
  total_ipv4_address_count = 16
  resource_group           = var.resource_group_id
  public_gateway           = ibm_is_public_gateway.gw_1.id
}

# Subnet 2 en la zona 2 (alta disponibilidad)
resource "ibm_is_subnet" "subnet_2" {
  name                     = "${var.prefix}-subnet-2"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = var.zone_2
  total_ipv4_address_count = 16
  resource_group           = var.resource_group_id
  public_gateway           = ibm_is_public_gateway.gw_2.id
}

# Security Group: permite HTTP (80), HTTPS (443), SSH (22) y todo el egress
resource "ibm_is_security_group" "sg" {
  name           = "${var.prefix}-sg"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id
}

resource "ibm_is_security_group_rule" "ingress_http" {
  group     = ibm_is_security_group.sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "ingress_https" {
  group     = ibm_is_security_group.sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "ingress_ssh" {
  group     = ibm_is_security_group.sg.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "egress_all" {
  group     = ibm_is_security_group.sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

output "vpc_id" {
  value = ibm_is_vpc.vpc.id
}

output "subnet_1_id" {
  value = ibm_is_subnet.subnet_1.id
}

output "subnet_2_id" {
  value = ibm_is_subnet.subnet_2.id
}

output "security_group_id" {
  value = ibm_is_security_group.sg.id
}
