#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

env | grep -E '^PACKER' | sort || true

shared_dir="$script_dir/../share"
mkdir -pv "$shared_dir"

VBoxManage sharedfolder add "${VM_NAME:-$PACKER_BUILD_NAME}" --name vboxsf --hostpath "$shared_dir" --automount --transient
