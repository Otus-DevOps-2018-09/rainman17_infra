provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_project_metadata" "ssh_keys" {
  metadata {
    ssh-keys = <<EOF
      root1:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxncFTUMRQrZeA5BVU0XOhh6BReDYHJrseWPNuNUcY5UG6RYRIJr6HxW/FtvZtDYK4UPlmBsJzvvzl76Jxc4lTWwsX1eR17bpQPwKeif0/XEFtBFJf61ivt4Qw1a0159GRl4oh/jrpsMCYboZPvFGpzw/tUBaYKUqmOi0Wy6ehTQL4II6AHaTfFnK+Ak+8GFLswoAtvq97PAjSLB0rcqD4UA1F9YGP0G3qyotMQq8iA7wFg3gLNUVHN/VQo6xNFKadxVqzX0ABBsJviqoOMdKehdLp+arzMW5K+NmDkAsKc6L1059TvObZJdt6NhTpGn6QnzoSqb/R0wn4OXcxGHCh root
      root2:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxncFTUMRQrZeA5BVU0XOhh6BReDYHJrseWPNuNUcY5UG6RYRIJr6HxW/FtvZtDYK4UPlmBsJzvvzl76Jxc4lTWwsX1eR17bpQPwKeif0/XEFtBFJf61ivt4Qw1a0159GRl4oh/jrpsMCYboZPvFGpzw/tUBaYKUqmOi0Wy6ehTQL4II6AHaTfFnK+Ak+8GFLswoAtvq97PAjSLB0rcqD4UA1F9YGP0G3qyotMQq8iA7wFg3gLNUVHN/VQo6xNFKadxVqzX0ABBsJviqoOMdKehdLp+arzMW5K+NmDkAsKc6L1059TvObZJdt6NhTpGn6QnzoSqb/R0wn4OXcxGHCh root
    EOF
  }
}

resource "google_compute_instance" "app" {
  name         = "reddit-app${count.index}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  count        = "${var.count}"

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать ephemeral IP для доступа из Интернет
    access_config {}
  }

  tags = ["reddit-app"]

  metadata {
    ssh-keys = "root:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "root"
    agent       = false
    private_key = "${file("${var.private_key_path}")}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}
