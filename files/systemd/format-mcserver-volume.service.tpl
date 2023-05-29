[Unit]
Description=Format ${ebs_volume_device}
After=${trimprefix(replace(ebs_volume_device, "/", "-"), "-")}.device
Requires=${trimprefix(replace(ebs_volume_device, "/", "-"), "-")}.device

[Service]
Type=oneshot
RemainAfterExit=true
# Only format the volume if it isn't already formatted
ExecStart=/bin/bash -c '\
  if file -s ${ebs_volume_device} | grep -q "data"; then \
    mkfs.xfs ${ebs_volume_device} -L mcserver; \
  fi'

[Install]
WantedBy=multi-user.target