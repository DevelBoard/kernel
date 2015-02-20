#!/bin/bash

# Prepend the AT91 nand flash specific header as stated by SAMA5D4 Datasheet
# in paragraph 13.4.4.1 "Detailed Memory Boot Procedures"

[ $# -ne 2 ] \
&& { echo "usage: <input_file> <output_file>"; exit 1; }

[ -f "$1" ] \
|| { echo "file not found: $1"; exit 1; }


nand_header() {
	# valid for SAMA5D4 Xplained board
	for i in `seq 1 52`; do
		printf '\x07\x4e\xe0\xc1'
	done
}

nand_header > "$2"
cat "$1" >> "$2"
chmod --reference="$1" "$2"
