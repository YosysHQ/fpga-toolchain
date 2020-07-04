#!/usr/bin/env bash
# -- Create package script

set -e

## --Create a tar.gz package

cd $PACKAGE_DIR/

echo $VERSION > VERSION

if [ $ARCH == "windows_x86" ]; then
    zip -r $NAME-$ARCH-$VERSION.zip $NAME
elif [ $ARCH == "windows_amd64" ]; then
    zip -r $NAME-$ARCH-$VERSION.zip $NAME
else
    tar -czf $NAME-$ARCH-$VERSION.tar.gz $NAME
fi
