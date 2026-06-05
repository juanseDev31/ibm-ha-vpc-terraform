variable "region" {
  description = "Región de IBM Cloud donde se despliega la infraestructura."
  type        = string
  default     = "us-east" # Washington DC
}

variable "prefix" {
  description = "Prefijo para nombrar todos los recursos (facilita identificación y limpieza)."
  type        = string
  default     = "ha-demo"
}

variable "resource_group" {
  description = "Nombre del resource group existente en tu cuenta de IBM Cloud."
  type        = string
  default     = "Default"
}

variable "zone_1" {
  description = "Primera zona de disponibilidad (Availability Zone)."
  type        = string
  default     = "us-east-1"
}

variable "zone_2" {
  description = "Segunda zona de disponibilidad para alta disponibilidad."
  type        = string
  default     = "us-east-2"
}

variable "vsi_profile" {
  description = "Perfil de las máquinas virtuales (balanced confidential computing)."
  type        = string
  default     = "bx3dc-2x10"
}

variable "image_name" {
  description = "Nombre de la imagen del sistema operativo (Ubuntu)."
  type        = string
  default     = "ibm-ubuntu-24-04-2-minimal-amd64-1"
}

variable "ssh_key_name" {
  description = "Nombre de la SSH key existente en tu cuenta de IBM Cloud."
  type        = string
}
