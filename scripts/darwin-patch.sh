#!/bin/bash
prog_name="$1"
if [ -z $prog_name ]
then
	echo "Usage $0 [target_name]"
	exit 1
fi

echo "Removing @rpath from $prog_name"
base_pkg=$(echo ${prog_name} | cut -d/ -f5)
install_name_tool -id $prog_name $prog_name || true
otool -L "$prog_name" | while read i
do
	if ! echo $i | grep -q "@rpath"
	then
		echo "    Skipping library [$i]"
		continue
	fi
	base_lib=$(echo "$i" | awk '{print $1}')
	new_path=$(echo "$base_lib" | sed 's|@rpath|/tmp/nextpnr/lib|')
	echo "    $prog_name: Removing rpath '$base_lib' -> '$new_path'"
	install_name_tool -change "$base_lib" "$new_path" "$prog_name"
done
otool -L "$prog_name"
echo ""