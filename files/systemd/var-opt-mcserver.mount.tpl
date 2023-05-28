[Unit]
Description=Mount ${mcserver_data_dir} Volume
After=format-mcserver-volume.service

[Mount]
What=${ebs_volume_device}
Where=${mcserver_data_dir}
Type=xfs

[Install]
WantedBy=multi-user.target