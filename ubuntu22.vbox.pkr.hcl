packer {
  required_version = ">= 1.7.0, < 2.0.0"
  required_plugins {
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

# http://releases.ubuntu.com/
variable "version" {
  type    = string
  default = "22.04"
}

variable "iso" {
  type    = string
  default = "ubuntu-22.04.3-live-server-amd64.iso"
}

variable "name"{
    type  = string
    default = ""
}

variable "checksum" {
  type    = string
  default = "a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
}

locals {
  name    = "ubuntu"
  vm_name = "${var.name}-${var.version}"
  url     = "http://releases.ubuntu.com/${var.version}/${var.iso}"
}

# https://developer.hashicorp.com/packer/plugins/builders/virtualbox/iso
source "virtualbox-iso" "ubuntu" {
  vm_name              = local.vm_name
  guest_os_type        = "Ubuntu_64"
  iso_url              = local.url
  iso_checksum         = var.checksum
  cpus                 = 2 
  memory               = 2042
  disk_size            = 40000
  disk_additional_size = []
  http_directory       = "installers"
  boot_wait            = "5s"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz autoinstall 'ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/' <enter><wait>",
    "initrd /casper/initrd <enter><wait>",
    "boot <enter>"
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
  name = local.name
  sources = [
    "source.virtualbox-iso.ubuntu",
  ]

  provisioner "file" {
    source      = "/var/log/installer/autoinstall-user-data"
    destination = "installers/autoinstall-user-data.new"
    direction   = "download"
  }

  provisioner "shell" {
    environment_vars = [
      "VM_NAME=${local.vm_name}"
    ]
    scripts = [
      "./scripts/comment_cdrom.sh",
      "./scripts/k8s_install.sh",
      "./scripts/k9s_install.sh"
    ]
    execute_command = "echo 'packer' | sudo -S -E bash '{{ .Path }}' '${packer.version}'"
  }

  post-processor "checksum" {
    checksum_types      = ["md5", "sha512"]
    keep_input_artifact = true
    output              =  "output-{{.BuildName}}/{{.BuildName}}.{{.ChecksumType}}"
  }

}
