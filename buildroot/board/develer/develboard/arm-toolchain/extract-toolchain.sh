#!/bin/bash

cd "$(dirname "$0")"

br_toolchain_dir="$HOST_DIR/usr"
tmpdir=/tmp/buildroot-toolchain-$$
mkdir -p "$tmpdir"

cleanup() {
	[ ! -d "$tmpdir" ] \
	|| rm -rf "$tmpdir" >/dev/null 2>&1
}

trap cleanup INT ERR TERM EXIT

echo -e "\nExtracting toolchain... from $br_toolchain_dir"
rsync -rlpDS "$br_toolchain_dir"/ "$tmpdir"/

tc_gcc="$br_toolchain_dir"/bin/arm-linux-gcc
tc_name="$(readlink "$tc_gcc" 2>/dev/null)"
tc_name="${tc_name%%-gcc}"
tc_arch="$BINARIES_DIR/${tc_name}.tar.gz"
[ -n "$tc_name" ] \
|| { echo "ERROR: could not readlink $tc_gcc"; exit 1; }

echo -e "\nPatching cross compiler rpath..."
# TODO: for a rpath like <...>/output/host/usr/<lib_path>, we can just pass output/host/usr
#       to patch-rpath.sh which performs a replacement like '$ORIGIN/<...>/<lib_path>
./patch-rpath.sh "$tmpdir" "$br_toolchain_dir/lib" "lib"
./patch-rpath.sh "$tmpdir" "$br_toolchain_dir/$tc_name/lib" "$tc_name/lib"

echo -e "\nCreating toolchain archive $tc_arch"
fakeroot tar czf "$tc_arch" -C"$tmpdir" .
