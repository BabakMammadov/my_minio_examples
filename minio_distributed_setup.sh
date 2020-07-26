# Do it below steps in  every server
# Disable firewall and selinux,
systemctl stop firewalld  && systemctl disable firewalld && setenforce 0 && sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config

# Install packages
wget -O /usr/local/bin/minio https://dl.minio.io/server/minio/release/linux-amd64/minio
chmod +x /usr/local/bin/minio



# Create service file
cat > /lib/systemd/system/minio.service << EOF
[Unit]
Description=minio
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
WorkingDirectory=/usr/local/
User=root
Group=root
EnvironmentFile=/etc/default/minio
ExecStart=/usr/local/bin/minio server \$MINIO_OPTS
Restart=always
LimitNOFILE=65536
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF

# Create minio enviroment file
cat > /etc/default/minio << EOF
MINIO_OPTS="http://minio01:9000/mnt/VHD http://minio02:9000/mnt/VHD http://minio03:9000/mnt/VHD http://minio04:9000/mnt/VHD"
MINIO_ACCESS_KEY="AKaHEgQ4II0S7BjT6DjAUDA4BX"
MINIO_SECRET_KEY="SKFzHq5iDoQgF7gyPYRFhzNMYSvY6ZFMpH"
EOF

# Start Minio  serivce
$ systemctl daemon-reload && systemctl start minio  && systemctl enable minio && systemctl status minio  | grep active

# Download minio client
$ wget https://dl.min.io/client/mc/release/linux-amd64/mc
$ cp mc /usr/local/bin
$ chmod +x /usr/local/bin/mc

# Add minio cluster to local for working
$ mc config host add minio_local_cluster http://localhost:9000   AKaHEgQ4II0S7BjT6DjAUDA4BX  SKFzHq5iDoQgF7gyPYRFhzNMYSvY6ZFMpH
Added `minio_local_cluster` successfully.


$ mc admin info minio_local_cluster
●  minio01:9000
   Uptime: 22 minutes 
   Version: 2020-07-24T22:43:05Z
   Network: 4/4 OK 
   Drives: 1/1 OK 

●  minio03:9000
   Uptime: 22 minutes 
   Version: 2020-07-24T22:43:05Z
   Network: 4/4 OK 
   Drives: 1/1 OK 

●  minio04:9000
   Uptime: 22 minutes 
   Version: 2020-07-24T22:43:05Z
   Network: 4/4 OK 
   Drives: 1/1 OK 

●  minio02:9000
   Uptime: 22 minutes 
   Version: 2020-07-24T22:43:05Z
   Network: 4/4 OK 
   Drives: 1/1 OK 

40 MiB Used, 1 Bucket, 4 Objects
4 drives online, 0 drives offline



$ mc admin heal minio_local_cluster
Background healing status:
 ●  0 item(s) scanned in total
 ●  Never executed

# For getting detailed info
$ mc admin --json info minio_local_cluster

# Create bucket
$ mc mb minio_local_cluster/mybucket01

# List bucket 
$ mc ls  minio_local_cluster/
[2020-07-25 21:38:31 UTC]      0B babak/
[2020-07-25 22:11:06 UTC]      0B mybucket01/
[2020-07-25 22:11:52 UTC]      0B mybucket02/
[2020-07-25 22:11:54 UTC]      0B mybucket03/

# cp files to bucket
mc cp  --recursive   /var/log/*  minio_local_cluster/babak

# List all files in bucket
mc ls --recursive   minio_local_cluster/babak


# Remove older than day ago files, --fake just for dry-run
mc rm --recursive --force --fake --older-than 30m  minio_local_cluster/babak
Removing `minio_local_cluster/babak/install-helm.sh`.
Removing `minio_local_cluster/babak/kafka.sh`.
Removing `minio_local_cluster/babak/zookeeper.sh`.
Removing `minio_local_cluster/babak/zoom_amd64.deb`.


# If you want to configure user-based access-control to buckets then you can use below link
https://docs.min.io/docs/minio-multi-user-quickstart-guide.html