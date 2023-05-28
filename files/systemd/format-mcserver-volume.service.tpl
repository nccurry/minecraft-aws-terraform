[Unit]
Description=Format ${ebs_volume_device}
After=${trimprefix(replace(ebs_volume_device, "/", "-"), "-")}.device
Requires=${trimprefix(replace(ebs_volume_device, "/", "-"), "-")}.device

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/usr/sbin/mkfs.xfs ${ebs_volume_device} -L mcserver

[Install]
WantedBy=multi-user.target