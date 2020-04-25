# -- Create package script

## --Create a tar.gz package

cd $PACKAGE_DIR/$NAME

echo $VERSION > VERSION

if [ $ARCH == "windows_x86" ]; then
    zip -r ../$NAME-$ARCH-$VERSION.zip *
elif [ $ARCH == "windows_amd64" ]; then
    zip -r ../$NAME-$ARCH-$VERSION.zip *
else
    tar -czvf ../$NAME-$ARCH-$VERSION.tar.gz *
fi