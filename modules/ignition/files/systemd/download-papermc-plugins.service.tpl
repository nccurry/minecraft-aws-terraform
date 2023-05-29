[Unit]
Description=Download PaperMC Plugins
After=Requires=var-opt-mcserver.mount

[Service]
Type=oneshot
ExecStart=/usr/local/bin/download-papermc-plugins.sh

[Install]
WantedBy=multi-user.target