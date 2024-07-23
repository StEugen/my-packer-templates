packer {
  required_version = ">= 1.7.0, < 2.0.0"
  required_plugins {
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "version" {
  type    = string
  default = "12" 
}

variable "iso" {
  type    = string
  default = "debian-12.0.0-amd64-DVD-1.iso"
}

variable "name"{
    type   = string
    default = ""
  }

variable "checksum" {
  type    = string
  default = "85042209e89908d5b59a968ff1be3c54415fa23015bf015562bad8d22452fa80"
}
locals {
  name    = "debian"
  url     = "https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/${var.iso}"
  vm_name = "${var.name}-${var.version}"
}

source "virtualbox-iso" "debian" {
  vm_name              = local.vm_name
  guest_os_type        = "Debian_64"
  iso_url              = local.url
  iso_checksum         = var.checksum
  cpus                 = 2
  memory               = 2048
  disk_size            = 40000
  disk_additional_size = []
  http_directory       = "installers"
  boot_wait = "5s"
  boot_command = [
    "<down><wait>",
    "<tab><wait>",
    "fb=true auto=true url=http://{{.HTTPIP}}:{{.HTTPPort}}/preseed.cfg hostname={{.Name}} domain=local <enter>"
  ]
  ssh_timeout      = "30m"
  ssh_username     = "packer"
  ssh_password     = "packer"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  rtc_time_base    = "UTC"
  bundle_iso       = false
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
  ]
  export_opts = [
    "--manifest",
    "--vsys", "0",
  ]
  format = "ova"
}

build {
  name = var.name

  sources = ["source.virtualbox-iso.debian"]
  provisioner "shell-local" {
    environment_vars = [
      "VM_NAME=${var.vm_name}"
    ]
    script = "./scripts/vboxsf.sh"
  }

  provisioner "shell" {
    scripts = [
      "./scripts/vboxsf_mount.sh",
      "./scripts/k8s_install.sh",
      "./scripts/ansible_install.sh",
    ]
    execute_command = "echo 'packer' | sudo -S -E bash '{{ .Path }}' '${packer.version}'"
  }

  post-processor "checksum" {
    checksum_types      = ["md5", "sha512"]
    keep_input_artifact = true
    output              = "output-{{.BuildName}}/{{.BuildName}}-${var.version}.{{.ChecksumType}}"
  }
}
