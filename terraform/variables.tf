variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  #Значение по умолчанию
  default = "ru-central1-a"
}
variable "public_key_path" {
  # Описание переменной
  description = "public key for ssh"
}
variable "image_id" {
  description = "Disk image"
}
variable "service_account_key_file" {
  description = "service account key file"
}

variable "private_key_path" {
  description = "private key path"
  default     = "~/.ssh/sm0ke"
}

variable "access_key" {
  description = "access_key"
}

variable "secret_key" {
  description = "secret_key"
}

variable "subnet_id" {
  default = "subnet for gitlab"
}

variable "network_id" {
  default = "network for gitlab"
}

variable "username" {
  description = "default username"
  default     = "sm0ke"
}
