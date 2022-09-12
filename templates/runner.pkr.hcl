packer {
    required_plugins {
        tart = {
            version = ">= 0.3.1"
            source  = "github.com/cirruslabs/tart"
        }
    }
}

variable "macos_version" {
    default = "monterey"
}

locals {
    runner_version = "2.296.2"
    runner_filename = "actions-runner-osx-arm64-${local.runner_version}.tar.gz"
    runner_url = "https://github.com/actions/runner/releases/download/v${local.runner_version}/${local.runner_filename}"
}

source "tart-cli" "tart" {
    vm_base_name = "${var.macos_version}-xcode"
    vm_name      = "${var.macos_version}-runner"
    cpu_count    = 4
    memory_gb    = 8
    disk_size_gb = 160
    ssh_password = "admin"
    ssh_username = "admin"
    ssh_timeout  = "120s"
}

build {
    sources = ["source.tart-cli.tart"]

    provisioner "shell" {
        inline = [
            "cd /Users/admin/",
            "mkdir actions-runner",
            "cd actions-runner",
            "echo ${local.runner_url}",
            "curl -O -L ${local.runner_url}",
            "tar -zxvf ${local.runner_filename}",
            "rm ${local.runner_filename}",
            "mkdir /Users/admin/.ssh",
            "echo \"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHQ2h6TVLCXRkfWBrPVHxYOu/FZWZzroEPXXKAoQZCKq\" > /Users/admin/.ssh/authorized_keys",
            "chmod 400 /Users/admin/.ssh/authorized_keys"
        ]
    }
}