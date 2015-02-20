#!/bin/bash

ROOTFSDIR=$1

echo "Prepend AT91 nand flash header to bootstrap"
board/develer/develboard/at91_nand_header.sh \
	output/images/sama5d4_xplained-nandflashboot-uboot-3.7.1.bin \
	output/images/at91bootstrap.bin

echo "Done"
