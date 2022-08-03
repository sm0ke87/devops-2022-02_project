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
  network_id = var.network_id
  master {
    version = "1.21"
    zonal {
      zone      = var.zone
      subnet_id = var.subnet_id
    }
    public_ip = true

    security_group_ids = [
      yandex_vpc_security_group.k8s-main-sg.id,
      yandex_vpc_security_group.k8s-master-whitelist.id
    ]

  }

  service_account_id      = yandex_iam_service_account.service.id
  node_service_account_id = yandex_iam_service_account.service.id
  depends_on = [
    yandex_resourcemanager_folder_iam_binding.admin,
    yandex_resourcemanager_folder_iam_binding.images-puller
  ]
  release_channel         = "RAPID"
  network_policy_provider = "CALICO"

}

resource "yandex_vpc_security_group" "k8s-main-sg" {
  name        = "k8s-main-sg"
  description = "Политики базовой работоспособности"
  network_id  = var.network_id
  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера и сервисов балансировщика."
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
    from_port      = 0
    to_port        = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol       = "ANY"
    description    = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера и сервисов."
    v4_cidr_blocks = ["10.128.0.0/24"]
    from_port      = 0
    to_port        = 65535
  }

  egress {
    protocol       = "ANY"
    description    = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Object Storage, Docker Hub и т. д."
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "k8s-public-services" {
  name        = "k8s-public-services"
  description = "Правила группы разрешают подключение к сервисам из интернета. Примените правила только для групп узлов."
  network_id  = var.network_id

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort."
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }
}

resource "yandex_vpc_security_group" "k8s-nodes-ssh-access" {
  name        = "k8s-nodes-ssh-access"
  description = "Rules for ssh access"
  network_id  = var.network_id

  ingress {
    protocol       = "TCP"
    description    = "Rules for ssh access"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}

resource "yandex_vpc_security_group" "k8s-master-whitelist" {
  name        = "k8s-master-whitelist"
  description = "Правила группы разрешают доступ к API Kubernetes из интернета."
  network_id  = var.network_id

  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к API Kubernetes через порт 6443 из указанной сети."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }
  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает подключение к API Kubernetes через порт 443 из указанной сети."
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
}


resource "yandex_iam_service_account" "service" {
  name        = "service"
  description = "deafult service"
}

resource "yandex_resourcemanager_folder_iam_binding" "admin" {
  # Сервисному аккаунту назначается роль "admin".
  folder_id = var.folder_id
  role      = "admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.service.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.service.id}"
  ]
}

resource "yandex_kubernetes_node_group" "nodes" {
  cluster_id = yandex_kubernetes_cluster.k8s.id

  instance_template {
    platform_id = "standard-v1"

    resources {
      cores  = 2
      memory = 4
    }

    boot_disk {
      size = 30
      type = "network-ssd"
    }

    network_interface {
      # Указан id подсети default-ru-central1-a
      subnet_ids = ["${var.subnet_id}"]
      nat        = true
      security_group_ids = [
        yandex_vpc_security_group.k8s-main-sg.id,
        yandex_vpc_security_group.k8s-nodes-ssh-access.id,
        yandex_vpc_security_group.k8s-public-services.id
      ]
    }

    metadata = {
      user-data = "${file("./metadata")}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }
}