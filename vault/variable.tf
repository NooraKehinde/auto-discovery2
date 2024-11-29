variable "ubuntu" {
  default = "ami-045a8ab02aadf4f88"
}
variable "vault_server_name" {
  default = "vault_server"
}
variable "vault_kms_key" {
  default = "vault_kms_key"
}
variable "vault_sg" {
  default = "vault_sg"
}
variable "domain" {
  default = "noektech.com"
}
variable "vault-domain" {
  default = "vault.noektech.com"
}