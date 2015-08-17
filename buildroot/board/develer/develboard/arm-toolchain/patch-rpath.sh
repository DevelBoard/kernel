#!/bin/bash

[ $# -eq 3 ] \
|| { echo "usage: $0 <buildroot_output_dir> <rpath_substr_to_match> <relative_lib_dir>"; \
	exit 1; }

which patchelf >/dev/null 2>&1 \
|| { echo "patchelf executable not found"; \
	exit 1; }

br_output_dir=$1
cd "$br_output_dir" \
|| exit 1

br_rpath_match=$2
br_lib_dir=$3

find . -type f -executable -print0 | while read -d $'\0' elf; do
	# discard non-ELF files
	file "$elf" | grep -q "ELF" \
	|| continue

	# filter rpath to match
	grep -q "$br_rpath_match" <<< "$(patchelf --print-rpath "$elf" 2>/dev/null)" \
	|| continue

	# get executable's depth of folder tree
	depth=$(grep -o '/' <<< "$elf" | wc -l)
	[ $depth -ge 2 ] \
	&& depth=$(($depth-1)) \
	|| continue

	# build the new rpath
	rpath='$ORIGIN'
	while [ $depth -gt 0 ]; do
		rpath="$rpath"/..
		depth=$(($depth-1))
	done
	rpath="$rpath/$br_lib_dir"

	# patch the rpath
	echo "patching rpath of $elf: $rpath"
	patchelf --set-rpath "$rpath" "$elf"
done
