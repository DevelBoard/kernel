#!/bin/bash

set -e
set -u

ROOTFSDIR="$BASE_DIR/target"
OUTPUTDIR="$BASE_DIR/images"
BOARDDIR="$PWD/board/develer/develboard"

echo "Prepend AT91 nand flash header to bootstrap"
"$BOARDDIR"/at91_nand_header.sh \
	"$OUTPUTDIR"/sama5d4_xplained-nandflashboot-barebox-*.bin \
	"$OUTPUTDIR"/.prefix-bootloader.bin

mv "$OUTPUTDIR"/.prefix-bootloader.bin \
    "$OUTPUTDIR"/develboard-nandflashboot-barebox.bin

mv "$OUTPUTDIR"/sama5d4_xplained-sdcardboot-barebox-*.bin \
    "$OUTPUTDIR"/develboard-sdcardboot-barebox.bin

rm "$OUTPUTDIR"/sama5d4_xplained-*.bin
rm "$OUTPUTDIR"/at91bootstrap.bin

mv "$OUTPUTDIR"/barebox-*-env "$OUTPUTDIR"/barebox.env || true


echo "Export kernel modules"
tar czf "$OUTPUTDIR"/modules.tar.gz -C"$ROOTFSDIR" lib/modules

echo "Done"
