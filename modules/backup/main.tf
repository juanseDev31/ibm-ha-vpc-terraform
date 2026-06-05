variable "prefix" {
  type        = string
  description = "Prefijo para nombrar recursos."
}

variable "resource_group_id" {
  type        = string
  description = "ID del resource group."
}

variable "backup_tag" {
  type        = string
  description = "User tag que marca qué volúmenes respaldar."
  default     = "backup-policy:daily"
}

# Política de backup: respalda todo recurso que tenga el user tag definido
resource "ibm_is_backup_policy" "policy" {
  name            = "${var.prefix}-backup-policy"
  resource_group  = var.resource_group_id
  match_user_tags = [var.backup_tag]
}

# Plan dentro de la política: snapshot diario a las 2:00 AM, conserva 7
resource "ibm_is_backup_policy_plan" "daily" {
  backup_policy_id = ibm_is_backup_policy.policy.id
  name             = "${var.prefix}-daily-plan"
  cron_spec        = "0 2 * * *" # todos los días a las 02:00
  active           = true

  deletion_trigger {
    delete_after = 7 # conserva los snapshots por 7 días
  }
}

output "backup_policy_id" {
  value = ibm_is_backup_policy.policy.id
}

output "backup_tag" {
  value = var.backup_tag
}
