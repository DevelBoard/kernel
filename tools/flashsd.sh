#!/bin/bash

set -e
set -u

dev=""
images=""
mnt_boot=""
mnt_data=""
part_boot=""
part_data=""

extract_rootfs=0
quick=0


function main {
    parse_args $@
    find_imagedir

    trap cleanup INT ERR TERM EXIT

    if [ $quick -eq 0 ]; then
        create_partitions
    fi

    mount_partitions
    copy_objects
}

function parse_args {
    if [ $# -eq 0 ]; then
        print_usage
    fi

    if [ "$1" == "--extract" ]; then
        extract_rootfs=1
        shift
    fi

    if [ "$1" == "--quick" ]; then
        quick=1
        shift
    fi

    dev="$1"

    if [ ! -b "$dev" ]; then
         echo "No such device: $dev"
         exit 1
    fi

    mnt_boot=/tmp/$$_boot
    mnt_data=/tmp/$$_data
    part_boot=${dev}1
    part_data=${dev}2
}

function print_usage {
    echo "usage: $(basename $0) [--extract] [--quick] </dev/sd?>"
    exit 1
}

function find_imagedir {
    if [ -d "build" -a -d "host" -a -d "images" ]; then
        images="$PWD/images"
    else
        images="$(dirname "$0")/../buildroot/output/images"
    fi
}

function cleanup {
    echo -n "* Exiting..."
    grep -q $mnt_boot /proc/mounts && sudo umount $mnt_boot && rm -rf $mnt_boot
    grep -q $mnt_data /proc/mounts && sudo umount $mnt_data && rm -rf $mnt_data
    echo "done!"

    trap - INT ERR TERM EXIT
}

function create_partitions() {
    echo "* Create partitions on $dev"

    # unmount all sd partitions
    mount -l | grep $dev | awk '{print $1}' | while read line; do
        [ -n "$line" ] && sudo umount $line
    done

    sudo sfdisk -uS --Linux --quiet $dev <<-EOF
2048,131072,e,*
133120,+,83,
EOF

    sudo partprobe $dev

    echo "* Format partitions on $dev"

    part_boot=${dev}1
    part_data=${dev}2

    sudo mkfs.vfat -F 16 $part_boot -n BOOT
    sudo mkfs.ext2 $part_data -L LINUX
}

function copy_objects() {
    echo "* Copy objects to sdcard"

    sudo cp $images/*sdcardboot*.bin $mnt_boot/BOOT.BIN
    sudo cp $images/*nandflashboot*.bin $mnt_boot/at91bootstrap.bin
    sudo cp $images/barebox.bin $mnt_boot/
    sudo cp $images/barebox.env $mnt_boot/
    sudo cp $images/zImage $mnt_boot/
    sudo cp $images/*.dtb $mnt_boot/

    if [ $extract_rootfs -eq 1 ]; then
        sudo tar xpf $images/rootfs.tar.gz -C $mnt_data/
    else
        sudo cp $images/rootfs.cpio.gz $mnt_data/
    fi

    sudo cp $images/rootfs.ubifs $mnt_data/

    echo "* Sync"
    sync
}

function mount_partitions() {
    echo "* Mount partitions"

    mkdir -p $mnt_boot && sudo mount $part_boot $mnt_boot
    mkdir -p $mnt_data && sudo mount $part_data $mnt_data
}

main $@
