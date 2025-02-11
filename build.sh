#!/bin/sh
# Build requirements: Python 3, Ruby, zip
set -e

if [ -e "font_manifests" ]
then
    echo "=== Copying font manifests... ==="
    cp font_manifests/regular repack/rom-repack/font/regular
    cp font_manifests/bold repack/rom-repack/font/bold
    echo "=== Running localization script... ==="
    node replace_chars.js
fi

echo "=== Building romfs... ==="
cd repack/rom-repack
ruby kal_real.rb ../../script.rb ../../romfs ../../patch.rom ../../patch.snr 6 19 88
cd ../..

echo "=== Building exefs... ==="
python3 build_exefs_text.py

echo "=== Generating mod directory structure... ==="
MODBASE=mods/contents/01006a300ba2c000/
mkdir -p $MODBASE/romfs/
mv patch.rom $MODBASE/romfs/patch.rom
cp -r exefs $MODBASE/exefs
mkdir -p mods/exefs_patches/umineko/
mv 7616F8963DACCD70E20FF3904E13367F96F2D9B3000000000000000000000000.ips mods/exefs_patches/umineko/
rm patch.snr

UMINEKO_TARGET_SUYU="/mnt/c/Users/YOUR NAME/AppData/Roaming/suyu"

if [ -e "$UMINEKO_TARGET_SUYU" ]
then # Local/dev build
    echo "=== This fails if you have Umineko Saku currently running ==="
    echo "=== Copying UminekoCatboxGerman directory structure to suyu... ==="
    MODBASE_SUYU=$UMINEKO_TARGET_SUYU/load/01006A300BA2C000/UminekoCatboxGerman
    mkdir -p "$MODBASE_SUYU/" 2> /dev/null || true
    cp -rf $MODBASE/* "$MODBASE_SUYU/"
    cp -rf mods/exefs_patches/umineko/*.ips "$MODBASE_SUYU/exefs/"
    rm -rf mods
    echo "Should work now, start suyu and the game."
else # Public build
    cd mods
    if [ "$SKIP_ARCHIVE" != "1" ]
    then
        zip -r ../patch_atmos.zip .
    fi
    cd ..
    mkdir UminekoCatboxGerman
    cp -r $MODBASE/* UminekoCatboxGerman/
    cp mods/exefs_patches/umineko/*.ips UminekoCatboxGerman/exefs/
    if [ "$SKIP_ARCHIVE" != 1 ]
    then
        zip -r patch_suyu.zip UminekoCatboxGerman
    fi
    cd ..
fi
