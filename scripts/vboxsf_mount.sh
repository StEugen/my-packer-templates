#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
	sudo="sudo"
else
	sudo=""
fi

mount_dir="/mnt/host"
$sudo mkdir -pv "$mount_dir"

echo "Mounting $mount_dir"
$sudo mount -t vboxsf vboxsf "$mount_dir"
.
log_file="/var/log/vboxadd-setup.log"
if [ -f "$log_file" ]; then
	cp -fv "$log_file" "$mount_dir/"
fi
