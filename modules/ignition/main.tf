terraform {
  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = ">= 0.13.0, < 1.0.0"
    }
  }
}

data "ct_config" "minecraft" {
  content = templatefile("${path.module}/files/ignition/butane.yaml.tpl", {
    data_volume_device_path = var.data_volume_device_path

    format_mcserver_volume_service_contents = templatefile("${path.module}/files/systemd/format-mcserver-volume.service.tpl", {
      mcserver_data_dir = var.mcserver_data_dir
      ebs_volume_device = var.data_volume_device_path
    })

    var_opt_mcserver_mount_contents = templatefile("${path.module}/files/systemd/var-opt-mcserver.mount.tpl", {
      mcserver_data_dir = var.mcserver_data_dir
      ebs_volume_device = var.data_volume_device_path
    })

    shutdown_when_inactive_sh_contents = file("${path.module}/files/scripts/shutdown-when-inactive.sh")
    shutdown_when_inactive_timer_contents = file("${path.module}/files/systemd/shutdown-when-inactive.timer")
    shutdown_when_inactive_service_contents = file("${path.module}/files/systemd/shutdown-when-inactive.service")

    download_papermc_plugins_service_contents = templatefile("${path.module}/files/systemd/download-papermc-plugins.service.tpl", {
      mcserver_data_dir = var.mcserver_data_dir
    })

    mcserver_service_contents = templatefile("${path.module}/files/systemd/mcserver.service.tpl", {
      mcserver_data_dir         = var.mcserver_data_dir
      papermc_container_image   = var.papermc_container_image
      papermc_container_tag     = var.papermc_container_tag
      papermc_server_memorysize = var.papermc_server_memory_size
    })

    updates_strategy_toml_contents = file("${path.module}/files/zincati/55-updates-strategy.toml")

    download_papermc_plugins_sh_contents = templatefile("${path.module}/files/scripts/download-papermc-plugins.sh.tpl", {
      mcserver_data_dir = var.mcserver_data_dir
    })
  })
  strict = true
}