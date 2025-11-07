#!/bin/bash
mkdir -p /mnt/usbcap/captures/
exec 2>>/var/log/rpi_capture.log
exec /usr/sbin/tcpdump -i eth0 -n -s 0 -G 3600 -w /mnt/usbcap/captures/cap_%Y%m%d-%H%M%S.pcap
