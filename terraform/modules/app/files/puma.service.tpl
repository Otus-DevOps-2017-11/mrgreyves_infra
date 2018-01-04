[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/home/appuser/reddit
ExecStart=/bin/bash -lc 'DATABASE_URL=${db_address} puma'
Restart=always

[Install]
WantedBy=multi-user.target
