#!/bin/bash

SOURCES_LIST="/etc/apt/sources.list"

if [ -f "$SOURCES_LIST" ]; then

	sudo sed -i '/^deb cdrom/ s/^/#/' "$SOURCES_LIST"
	sudo apt update
	echo "Lines containing 'deb cdrom' have been commented out in $SOURCES_LIST."
else
	echo "File $SOURCES_LIST does not exist."
fi
