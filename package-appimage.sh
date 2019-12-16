#! /bin/bash


APP=hugin
#APP_VERSION=0.5.0
LOWERAPP=${APP,,} 


# Get the helper scripts and load the helper functions
(mkdir -p /work && cd /work && rm -rf appimage-helper-scripts && \
git clone https://github.com/aferrero2707/appimage-helper-scripts.git) || exit 1
source /work/appimage-helper-scripts/functions.sh


# Create the root AppImage folder
export APPIMAGEBASE=/work/appimage
export APPDIR="${APPIMAGEBASE}/$APP.AppDir"
(rm -rf "${APPIMAGEBASE}" && mkdir -p "${APPIMAGEBASE}/$APP.AppDir/usr/bin") || exit 1
cp /work/appimage-helper-scripts/excludelist "${APPIMAGEBASE}"


cp -a "/usr/local/bin"/* "$APPDIR/usr/bin"
cp -a "/usr/local/share" "$APPDIR/usr"
#cp "$APPDIR/usr/share/pixmaps/$LOWERAPP.png" "$APPDIR/$LOWERAPP.png"



mkdir -p "$APPDIR/usr/share/icons"
mkdir -p "$APPDIR/usr/share/applications"


source /work/appimage-helper-scripts/bundle-gtk2.sh


#get_apprun
cp -a /sources/AppRun "$APPDIR/AppRun" || exit 1
cp -a /work/appimage-helper-scripts/apprun-helper.sh "$APPDIR/apprun-helper.sh" || exit 1
mkdir -p "$APPDIR/usr/share/metainfo" || exit 1
#cp "/sources/${APP}.appdata.xml" "$APPDIR/usr/share/metainfo/${APP}.appdata.xml" || exit 1
cp "/usr/local/share/appdata/hugin.appdata.xml" "$APPDIR/usr/share/metainfo/${APP}.appdata.xml" || exit 1
cp -a "/usr/local/share/appdata" "$APPDIR/usr/share" || exit 1

# Copy Qt5 plugins
QT5PLUGINDIR=$(pkg-config --variable=plugindir Qt5)
if [ x"$QT5PLUGINDIR" != "x" ]; then
  mkdir -p "$APPDIR/usr/lib/qt5/plugins"
  cp -a "$QT5PLUGINDIR"/* "$APPDIR/usr/lib/qt5/plugins"
fi


export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Get into the AppImage
cd "$APPDIR"


# Copy in the indirect dependencies
copy_deps2 ; copy_deps2 ; copy_deps2 # Three runs to ensure we catch indirect ones

move_lib
echo ""
echo "ls usr/lib"
ls usr/lib


delete_blacklisted2
# Put the gcc libraries in optional folders
copy_gcc_libs


# patch_usr
# Patching only the executable files seems not to be enough for darktable
#find usr/ -type f -exec sed -i -e "s|$PREFIX|././|g" {} \;
#find usr/ -type f -exec sed -i -e "s|/usr|././|g" {} \;


(cd /work/appimage-helper-scripts/appimage-exec-wrapper2 && make && cp -a exec.so "$APPDIR/usr/lib/exec_wrapper2.so") || exit 1



# Workaround for:
# GLib-GIO-ERROR **: Settings schema 'org.gtk.Settings.FileChooser' is not installed
# when trying to use the file open dialog
# AppRun exports usr/share/glib-2.0/schemas/ which might be hurting us here
( mkdir -p usr/share/glib-2.0/schemas/ ; cd usr/share/glib-2.0/schemas/ ; ln -s /usr/share/glib-2.0/schemas/gschemas.compiled . )

# Workaround for:
# ImportError: /usr/lib/x86_64-linux-gnu/libgdk-x11-2.0.so.0: undefined symbol: XRRGetMonitors
cp $(ldconfig -p | grep libgdk-x11-2.0.so.0 | cut -d ">" -f 2 | xargs) ./usr/lib/
cp $(ldconfig -p | grep libgtk-x11-2.0.so.0 | cut -d ">" -f 2 | xargs) ./usr/lib/

GLIBC_NEEDED=$(glibc_needed)
#export VERSION=$(git rev-parse --short HEAD)-$(date +%Y%m%d).glibc$GLIBC_NEEDED
#export VERSION=git-$(date +%Y%m%d)
export VERSION=2019.2.0_rc3-$(date +%Y%m%d)
echo $VERSION

cd "$APPDIR"

get_desktop
get_icon

get_desktopintegration $LOWERAPP
#cp -a ../../desktopintegration ./usr/bin/$LOWERAPP.wrapper
#chmod a+x ./usr/bin/$LOWERAPP.wrapper
#sed -i -e "s|Exec=$LOWERAPP|Exec=$LOWERAPP.wrapper|g" $LOWERAPP.desktop

# Go out of AppImage
cd ..

mkdir -p ../out/
ARCH="x86_64"
export NO_GLIBC_VERSION=true
export DOCKER_BUILD=true
generate_type2_appimage

pwd
ls ../out/*
mkdir -p /sources/out
cp ../out/*.AppImage /sources/out

########################################################################
# Upload the AppDir
########################################################################

#transfer ../out/*
#echo ""
#echo "AppImage has been uploaded to the URL above; use something like GitHub Releases for permanent storage"
