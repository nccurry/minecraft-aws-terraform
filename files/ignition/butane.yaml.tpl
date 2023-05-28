variant: fcos
version: 1.5.0
storage:
  directories:
  - user:
      name: core
    group:
      name: core
    path: /opt/mcserver
    mode: 504
  files:
  - path: /etc/zincati/config.d/55-updates-strategy.toml
    contents:
      source: "data:,${url_encoded_zincati_config}"
systemd:
  units:
  - name: format-mcserver-volume.service
    enabled: true
    contents: |
      ${indent(6, format_mcserver_volume_service_contents)}
  - name: var-opt-mcserver.mount
    enabled: true
    contents: |
      ${indent(6, var_opt_mcserver_mount_contents)}
  - name: download-papermc-plugins.service
    enabled: true
    contents: |
      ${indent(6, download_papermc_plugins_service_contents)}
  - name: mcserver.service
    enabled: true
    contents: |
      ${indent(6, mcserver_service_contents)}
