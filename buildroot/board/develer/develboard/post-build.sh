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

echo "Add rootfs additions"
rsync -rlpDSv "$BOARDDIR"/rootfs-additions/ "$ROOTFSDIR"/

echo "Done"
