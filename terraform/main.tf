terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}


provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

resource "yandex_compute_instance" "runner" {
  name        = "runner"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  hostname    = "runner"
  


  resources {
    cores  = 2
    memory = 2

  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 20
      type     = "network-ssd"

    }
  }
  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true

  }

  metadata = {
    user-data = "${file("./metadata")}"
  }

  provisioner "local-exec" {
    command = "sleep 30;ANSIBLE_CONFIG=../gitlab-runner-ansible/ansible.cfg ansible-playbook -u ${var.username} -e address='${self.network_interface.0.nat_ip_address} GTILAB_URL=${yandex_compute_instance.gitlab.network_interface.0.nat_ip_address}' -i '${yandex_compute_instance.runner.network_interface.0.nat_ip_address},' ../gitlab-runner-ansible/playbook.yml"
  }

  depends_on = [yandex_compute_instance.gitlab]
}

resource "yandex_compute_instance" "gitlab" {
  name        = "gitlab"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  hostname    = "gitlab"

  resources {
    cores  = 2
    memory = 6

  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 50
      type     = "network-ssd"

    }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true

  }

  metadata = {
    user-data = "${file("./metadata")}"
  }

  provisioner "local-exec" {
    command = "sleep 30;ANSIBLE_CONFIG=../gitlab-ansible/ansible.cfg ansible-playbook -u ${var.username} -e 'address=${self.network_interface.0.nat_ip_address}'  -i '${yandex_compute_instance.gitlab.network_interface.0.nat_ip_address},' ../gitlab-ansible/playbook.yml"
  }
}

resource "yandex_kubernetes_cluster" "k8s" {
 network_id = yandex_vpc_network.<имя сети>.id
 master {
   zonal {
     zone      = yandex_vpc_subnet.<имя подсети>.zone
     subnet_id = yandex_vpc_subnet.<имя подсети>.id
   }
 }
 service_account_id      = yandex_iam_service_account.service-acc.id
 node_service_account_id = yandex_iam_service_account.service-acc.id
   depends_on = [
     yandex_resourcemanager_folder_iam_binding.editor,
     yandex_resourcemanager_folder_iam_binding.images-puller
   ]
}

resource "yandex_vpc_network" "<имя сети>" { name = "<имя сети>" }

resource "yandex_vpc_subnet" "<имя подсети>" {
 v4_cidr_blocks = ["<диапазон адресов подсети>"]
 zone           = "<зона доступности>"
 network_id     = yandex_vpc_network.<имя сети>.id
}

resource "yandex_iam_service_account" "<имя сервисного аккаунта>" {
 name        = "<имя сервисного аккаунта>"
 description = "<описание сервисного аккаунта>"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
 # Сервисному аккаунту назначается роль "editor".
 folder_id = "<идентификатор каталога>"
 role      = "editor"
 members   = [
   "serviceAccount:${yandex_iam_service_account.<имя сервисного аккаунта>.id}"
 ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
 # Сервисному аккаунту назначается роль "container-registry.images.puller".
 folder_id = "<идентификатор каталога>"
 role      = "container-registry.images.puller"
 members   = [
   "serviceAccount:${yandex_iam_service_account.<имя сервисного аккаунта>.id}"
 ]
}