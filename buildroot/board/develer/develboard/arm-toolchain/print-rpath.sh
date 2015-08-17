#!/bin/bash

[ $# -eq 1 ] \
|| { echo "usage: $0 <toolchain_dir>"; \
	exit 1; }

which patchelf >/dev/null 2>&1 \
|| { echo "patchelf executable not found"; \
	exit 1; }

tc_dir=$1
cd "$tc_dir" \
|| exit 1

find . -type f -executable -print0 | while read -d $'\0' elf; do
	rpath="$(patchelf --print-rpath "$elf" 2>/dev/null)"
	[ -n "$rpath" ] \
	|| continue;

	echo $elf: $rpath
done
