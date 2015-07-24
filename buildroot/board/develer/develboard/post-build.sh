#!/bin/bash

set -e
set -u

ROOTFSDIR="$BASE_DIR/target"
OUTPUTDIR="$BASE_DIR/images"
BOARDDIR="$PWD/board/develer/develboard"

echo "Prepend AT91 nand flash header to bootstrap"
"$BOARDDIR"/at91_nand_header.sh \
	"$OUTPUTDIR"/sama5d4_xplained-nandflashboot-uboot-3.7.1.bin \
	"$OUTPUTDIR"/at91bootstrap.bin

echo "Remove sysvinit compatibility scripts"
rm -rf "$ROOTFSDIR/etc/init.d"

echo "Disable dropbear.service"
rm -f "$ROOTFSDIR/etc/systemd/system/multi-user.target.wants/dropbear.service"

echo "Enable dropbear.socket (socket activation)"
ln -sf "$ROOTFSDIR/etc/systemd/system/dropbear.socket" "$ROOTFSDIR/etc/systemd/system/multi-user.target.wants/dropbear.socket"

echo "Done"
