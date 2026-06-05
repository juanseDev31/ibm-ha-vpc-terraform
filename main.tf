# ---------------------------------------------------------------------------
# Data sources: obtienen información de recursos existentes en tu cuenta
# ---------------------------------------------------------------------------
data "ibm_resource_group" "rg" {
  name = var.resource_group
}

data "ibm_is_ssh_key" "ssh_key" {
  name = var.ssh_key_name
}

data "ibm_is_image" "ubuntu" {
  name = var.image_name
}

# ---------------------------------------------------------------------------
# Módulo de red: VPC, 2 subnets en zonas distintas, security group, gateways
# ---------------------------------------------------------------------------
module "network" {
  source            = "./modules/network"
  prefix            = var.prefix
  resource_group_id = data.ibm_resource_group.rg.id
  zone_1            = var.zone_1
  zone_2            = var.zone_2
}

# ---------------------------------------------------------------------------
# Módulo de backup: política de snapshots para los volúmenes de las VSI
# Se define primero para que su tag esté disponible al crear las VSI
# ---------------------------------------------------------------------------
module "backup" {
  source            = "./modules/backup"
  prefix            = var.prefix
  resource_group_id = data.ibm_resource_group.rg.id
}

# ---------------------------------------------------------------------------
# Módulo de cómputo: 2 VSI Ubuntu, una en cada subnet/zona
# ---------------------------------------------------------------------------
module "compute" {
  source            = "./modules/compute"
  prefix            = var.prefix
  resource_group_id = data.ibm_resource_group.rg.id
  vpc_id            = module.network.vpc_id
  vsi_profile       = var.vsi_profile
  image_id          = data.ibm_is_image.ubuntu.id
  ssh_key_id        = data.ibm_is_ssh_key.ssh_key.id
  security_group_id = module.network.security_group_id
  backup_tag        = module.backup.backup_tag

  instances = [
    {
      name      = "web-1"
      subnet_id = module.network.subnet_1_id
      zone      = var.zone_1
    },
    {
      name      = "web-2"
      subnet_id = module.network.subnet_2_id
      zone      = var.zone_2
    }
  ]
}

# ---------------------------------------------------------------------------
# Módulo de balanceador: Application Load Balancer público entre las 2 VSI
# ---------------------------------------------------------------------------
module "loadbalancer" {
  source            = "./modules/loadbalancer"
  prefix            = var.prefix
  resource_group_id = data.ibm_resource_group.rg.id
  subnet_ids        = [module.network.subnet_1_id, module.network.subnet_2_id]
  vpc_id            = module.network.vpc_id
  member_ips        = module.compute.private_ips
}
