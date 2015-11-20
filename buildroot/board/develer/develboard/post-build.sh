#!/bin/bash

set -e
set -u

ROOTFSDIR="$BASE_DIR/target"
OUTPUTDIR="$BASE_DIR/images"
BOARDDIR="$PWD/board/develer/develboard"

mv "$OUTPUTDIR"/sama5d4_xplained-nandflashboot-barebox-*.bin \
    "$OUTPUTDIR"/develboard-nandflashboot-barebox.bin

mv "$OUTPUTDIR"/sama5d4_xplained-sdcardboot-barebox-*.bin \
    "$OUTPUTDIR"/develboard-sdcardboot-barebox.bin

rm "$OUTPUTDIR"/at91bootstrap.bin

mv "$OUTPUTDIR"/barebox-*-env "$OUTPUTDIR"/barebox.env || true


echo "Export kernel modules"
tar czf "$OUTPUTDIR"/modules.tar.gz -C"$ROOTFSDIR" lib/modules -C"$BOARDDIR"/rootfs-overlay-wifi lib/firmware

echo "Done"
