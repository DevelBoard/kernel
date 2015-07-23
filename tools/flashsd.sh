#!/bin/bash

set -e
cd "`dirname "$0"`"

[ $1 == "--quick" ] \
&& { QUICK=1; shift; }

[ $# -eq 1 ] \
|| { echo "usage: $(basename $0) [--quick] </dev/sd?>"; exit 1; }

dev=$1
[ -b $dev ] \
|| { echo "No such device: $dev"; exit 1; }


[ -z $QUICK ] && echo "* Create partitions on $dev"

# unmount all sd partitions
[ -z $QUICK ] && mount -l | grep $dev | awk '{print $1}' | while read line; do
	[ -n "$line" ] && sudo umount $line
done

[ -z $QUICK ] && sudo sfdisk -uS --Linux --quiet $dev <<-EOF
	2048,131072,e,*
	133120,+,83,
EOF

[ -z $QUICK ] && sudo partprobe $dev


[ -z $QUICK ] && echo "* Format partitions on $dev"

part_boot=${dev}1
part_data=${dev}2

[ -z $QUICK ] && sudo mkfs.vfat -F 16 $part_boot -n BOOT
[ -z $QUICK ] && sudo mkfs.ext2 $part_data -L LINUX

mnt_boot=/tmp/$$_boot
mnt_data=/tmp/$$_data

function cleanup {
	echo -n "* Exiting..."
	grep -q $mnt_boot /proc/mounts && sudo umount $mnt_boot && rm -rf $mnt_boot
	grep -q $mnt_data /proc/mounts && sudo umount $mnt_data && rm -rf $mnt_data
	echo "done!"

	trap - INT ERR TERM EXIT
}
trap cleanup INT ERR TERM EXIT

mkdir -p $mnt_boot && sudo mount $part_boot $mnt_boot
mkdir -p $mnt_data && sudo mount $part_data $mnt_data


echo "* Copy objects to sdcard"

images=../buildroot/output/images

sudo cp $images/*sdcardboot*.bin $mnt_boot/BOOT.BIN
sudo cp $images/at91bootstrap.bin $mnt_boot/
sudo cp $images/barebox.bin $mnt_boot/u-boot.bin
sudo cp $images/barebox-*-env $mnt_boot/barebox.env
sudo cp $images/zImage $mnt_boot/
sudo cp $images/*.dtb $mnt_boot/
sudo cp $images/rootfs.ubifs $mnt_data/
sudo cp $images/rootfs.cpio.gz $mnt_data/

sync

