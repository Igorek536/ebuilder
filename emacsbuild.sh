#!/usr/bin/env bash

# Emacs build script. Put it in directory with sources.

export TARGETPATH="/opt/emacs-git"
export COMPILEBIN="bin/emacs"
export SYSTEMBIN="emacs-git"
export DESKTOPNAME="Emacs-git"

# / ------------------------------ \
# |  DO NOT EDIT THE LINES BELOW!  |
# \ ------------------------------ /

export BINLINK="/usr/local/bin/$SYSTEMBIN"
export DESKFILE="/usr/share/applications/$DESKTOPNAME.desktop"

if [ $EUID -ne 0 ]; then
   echo "This script must be run as root"
   exit 1
fi

if [ -f $BINLINK ]; then
    rm $BINLINK
fi

if [ -f $DESKFILE ]; then
    rm $DESKFILE
fi

if [ -d "$TARGETPATH" ]; then
    rm -rf $TARGETPATH
    mkdir $TARGETPATH
else
    mkdir $TARGETPATH
fi

if [ ! -f ./icon.png ]; then
    echo "icon.png not found!"
    exit 1
fi

echo "Welcome to emacs autobuilder!"

export SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
export DIR="$(dirname "$SCRIPT")"
export CORES="$(getconf _NPROCESSORS_ONLN)"

echo -e "\nYou have $CORES of CPU\n"

$DIR/configure --prefix="$TARGETPATH" --exec-prefix="$TARGETPATH"

make clean
make bootstrap -j$CORES
echo -e "\n\nCompilation finished, installing to $TARGETPATH!\n\n"
make install
ln -s "$TARGETPATH/$COMPILEBIN" "$BINLINK"
cp $DIR/icon.png $TARGETPATH

echo -e \
"[Desktop Entry]
Type=Application
Version=1.0
Name=$DESKTOPNAME
Comment=Emacs from git
Path=
Exec=emacs-git
Icon=$TARGETPATH/icon.png
Terminal=false
Categories=Development" > $DESKFILE

echo "Desktop file installed to $DESKFILE"
echo -e "\n\n\nTo uninstall $DESKTOPNAME run $SYSTEMBIN-uninstall as root!\n\n\n"

echo -e \
"#!/usr/bin/env bash
# Script for uninstalling Emacs-git.

echo -e \"\nEmacs-git uninstaller!\n\"

if [ \$EUID -ne 0 ]; then
   echo \"\nThis script must be run as root\n\"
   exit 1
fi

if [ -f \"$DESKFILE\" ]; then
   rm $DESKFILE
fi

if [ -f \"$BINLINK\" ]; then
   rm $BINLINK
fi

if [ -d \"$TARGETPATH\" ]; then
   rm -rf $TARGETPATH
fi

if [ -f \"$BINLINK-uninstall\" ]; then
   echo \"\n$DESKTOPNAME uninstalled!\n\"
   rm $BINLINK-uninstall
fi
" > $BINLINK-uninstall
chmod +x $BINLINK-uninstall
