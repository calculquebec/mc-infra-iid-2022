terraform {
  required_version = ">= 1.1.0"
}

variable "email" {}
variable "password" {}

module "openstack" {
  source         = "git::https://github.com/ComputeCanada/magic_castle.git//openstack?ref=ext_data"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
  config_version = "11.9.0"

  cluster_name = "iid-2022"
  domain       = "calculquebec.cloud"
  image        = "Rocky-8.5-x64-2021-11"

  instances = {
    mgmt   = { type = "p4-6gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
    login  = { type = "p2-3gb", tags = ["login", "public", "proxy"], count = 1 }
    node   = { type = "p2-3gb", tags = ["node"], count = 3 }
  }

  volumes = {
    nfs = {
      home     = { size = 50 }
      project  = { size = 50 }
      scratch  = { size = 50 }
    }
  }

  public_keys = [
"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCy6vaeMkT+8lNOpvG+scN1iiRby35dGLyh1s3NOzufzqjAVvZL6t/vd7CN/hbTg+UUCc3V1hJOxGFGD3lrbXho1R5S4pZZ+Hge3icJm4BAPX6O9+H7aMWh/DE/vxHhyyC5QX8vg3AqUtCjihT03xftCC1XGzcP5lvs/bWgn1RS3pXY85UGY80NsRiGK08HpRER7ifNbo9zipIO4eQpRvTq6Ent5mqmeULMRX99SAbgUciaz5mUcULw5OimNFSjakdDRyF2xrdVsX6mwHPUT3UIXAxxS5GGTWIIH+jG0L0rqnjtnRwj8Imw+zOtE5itMg4kCNO+q5KJBH1jU6g57JFiEoxviHQH1ATlsw8e6gI2nhkfi10NgIzQ/yLxsK3IS4XwqMqDRInf6eGrf1CvbxYjOvpm7pOvLbvBdSrH+Ynx5X743oNIAmwjSoJ+ABa1RQp0XNrDfQXYmRrCA3sKgh/bOge+B8HDVEkCdSv+bAp/4rfGOKy4eOPsuzvrxnS8OWNet0+bAUV1Ta0VigHlFgEvQtS4/jrOO3It0ZaYMIZFAWqsjXimJ5LiT1TAgOCUO9950ZUA8BWQuSO+/EzREPCThRvFPKy82HAPOY8fo3jrEekuJdrjF8IDHxYL51YR+WPupY52HCHZkg4iDxKXnkrLS3K5/AIa5/+/CnHWL5WGHw== felix@armor.local",
]

  nb_users = 100
  guest_passwd = var.password
  generate_ssh_key = true
}


output "accounts" {
  value = module.openstack.accounts
}

output "public_ip" {
  value = module.openstack.public_ip
}

## Uncomment to register your domain name with CloudFlare
module "dns" {
  source           = "git::https://github.com/ComputeCanada/magic_castle.git//dns/cloudflare?ref=ext_data"
  email            = var.email
  name             = module.openstack.cluster_name
  domain           = module.openstack.domain
  public_instances = module.openstack.public_instances
  ssh_private_key  = module.openstack.ssh_private_key
  sudoer_username  = module.openstack.accounts.sudoer.username
}

## Uncomment to register your domain name with Google Cloud
# module "dns" {
#   source           = "git::https://github.com/ComputeCanada/magic_castle.git//dns/gcloud"
#   email            = "you@example.com"
#   project          = "your-project-id"
#   zone_name        = "you-zone-name"
#   name             = module.openstack.cluster_name
#   domain           = module.openstack.domain
#   public_instances = module.openstack.public_instances
#   ssh_private_key  = module.openstack.ssh_private_key
#   sudoer_username  = module.openstack.accounts.sudoer.username
# }

output "hostnames" {
  value = module.dns.hostnames
}
