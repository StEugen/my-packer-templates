#!/bin/bash

wget https://github.com/derailed/k9s/releases/download/v0.32.4/k9s_linux_amd64.deb

echo packer | sudo dpkg -i k9s_linux_amd64.deb
