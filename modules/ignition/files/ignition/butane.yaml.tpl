variant: fcos
version: 1.5.0
storage:
  filesystems:
  - device: ${data_volume_device_path}
    path: /var/opt/mcserver
    format: xfs
    label: mcserver
    with_mount_unit: true
  directories:
  - user:
      name: core
    group:
      name: core
    path: /var/opt/mcserver
    mode: 0770
  files:
  - path: /etc/zincati/config.d/55-updates-strategy.toml
    contents:
      inline: |
        ${indent(8, updates_strategy_toml_contents)}
  - path: /usr/local/bin/download-papermc-plugins.sh
    contents:
      inline: |
        ${indent(8, download_papermc_plugins_sh_contents)}
    mode: 0774
  - path: /usr/local/bin/shutdown-when-inactive.sh
    contents:
      inline: |
        ${indent(8, shutdown_when_inactive_sh_contents)}
    mode: 0774
systemd:
  units:
  - name: shutdown-when-inactive.timer
    enabled: true
    contents: |
      ${indent(6, shutdown_when_inactive_timer_contents)}
  - name: shutdown-when-inactive.service
    enabled: false
    contents: |
      ${indent(6, shutdown_when_inactive_service_contents)}
  - name: download-papermc-plugins.service
    enabled: true
    contents: |
      ${indent(6, download_papermc_plugins_service_contents)}
  - name: mcserver.service
    enabled: true
    contents: |
      ${indent(6, mcserver_service_contents)}
