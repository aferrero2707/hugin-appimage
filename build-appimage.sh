
yum update -y && yum install -y epel-release && yum update -y || exit 1
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
yum repolist
yum install -y centos-release-scl || exit 1
yum install -y devtoolset-4-gcc devtoolset-4-gcc-c++ || exit 1

#yum group install -y "Development Tools"
(yum install -y autoconf automake libtool file patch make cmake3 mercurial bzip2 git gettext-devel fftw-devel exiv2-devel zlib-devel wget cairo libtiff-devel libjpeg-turbo-devel gtk2-devel OpenEXR-devel glew-devel libpano13-devel boost-devel lcms2-devel sqlite-devel libcroco-devel libxml2-devel gobject-introspection-devel cairo-gobject-devel gsl-devel) || exit 1

source scl_source enable devtoolset-4


#export PKG_CONFIG_PATH=

mkdir -p /work



echo ""
echo "########################################################################"
echo ""
echo "Building and installing vigra"
echo ""

cd /work
if [ ! -e vigra ] ; then
#rm -rf vigra
git clone https://github.com/ukoethe/vigra.git || exit 1
cd vigra || exit 1
rm -rf vigra-build
mkdir -p vigra-build || exit 1
cd vigra-build || exit 1
cmake3 -DWITH_OPENEXR=1  -DCMAKE_INSTALL_PREFIX=/usr/local ../ || exit 1
make -j 3 install || exit 1
fi

echo ""
echo "########################################################################"
echo ""
echo "Building and installing enblend"
echo ""

cd /work
if [ ! -e enblend ]; then
#rm -rf enblend
hg clone http://hg.code.sf.net/p/enblend/code enblend || exit 1 
cd enblend || exit 1
git clone https://github.com/akrzemi1/Optional.git Optional-master || exit 1
mkdir enblend-build || exit 1
cd enblend-build || exit 1
#CXXFLAGS='-std=gnu++1y' CPPFLAGS='-I/opt/rh/devtoolset-4/root/usr/include/c++/5.3.1/experimental' 
cmake3 -DSOURCE_BASE_DIR="/work/enblend" -DCMAKE_INSTALL_PREFIX=/usr/local ../ || exit 1
make -j 3 install || exit 1
fi
cd ..


echo ""
echo "########################################################################"
echo ""
echo "Building and installing librsvg"
echo ""

export PATH=$HOME/.cargo/bin:$PATH
if [ ! -e /work/librsvg-2.40.16 ]; then
(cd /work && curl https://sh.rustup.rs -sSf > ./r.sh && bash ./r.sh -y && \
rm -rf librsvg* && wget http://ftp.gnome.org/pub/gnome/sources/librsvg/2.40/librsvg-2.40.16.tar.xz && \
tar xf librsvg-2.40.16.tar.xz && cd librsvg-2.40.16 && \
./configure --prefix=/usr/local && make -j 3 install) || exit 1
fi



echo ""
echo "########################################################################"
echo ""
echo "Building and installing wxWidgets"
echo ""

cd /work
if [ ! -e wxWidgets-3.0.4 ]; then
#rm -rf wxWidgets-*
wget https://github.com/wxWidgets/wxWidgets/releases/download/v3.0.4/wxWidgets-3.0.4.tar.bz2 || exit 1
tar xf wxWidgets-3.0.4.tar.bz2 || exit 1
cd wxWidgets-3.0.4 || exit 1
mkdir -p wx-build || exit 1
cd wx-build || exit 1
../configure --enable-unicode --with-opengl --prefix=/usr/local || exit 1
make -j 3 install || exit 1
fi

echo ""
echo "########################################################################"
echo ""
echo "Building and installing hugin"
echo ""

if [ ! -e /work/hugin ]; then
cd /work
#rm -rf hugin
#hg clone --verbose http://hg.code.sf.net/p/hugin/hugin -r 899a2acfda64 hugin || exit 1
#hg clone --verbose http://hg.code.sf.net/p/hugin/hugin -r 75168618c648 hugin || exit 1
#hg clone --verbose http://hg.code.sf.net/p/hugin/hugin -r fcbac34304f4f8becc1db9d257da61b0cd763e58 || exit 1 # 2019.0.0_rc1
hg clone --verbose http://hg.code.sf.net/p/hugin/hugin -r 22e4831af00ece14191adc7868b24caab1f053c6 || exit 1 # 2019.0.0
#hg clone --verbose http://hg.code.sf.net/p/hugin/hugin hugin || exit 1
cd hugin || exit 1
#patch -N -p1 < /sources/hugin-bundle.patch #|| exit 1
rm -rf hugin-build
mkdir -p hugin-build || exit 1
cd hugin-build || exit 1
cmake3 -DCMAKE_INSTALL_PREFIX=/usr/local \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_HSI:BOOL=OFF \
	-DUSE_GDKBACKEND_X11:BOOL=ON \
	-DUNIX_SELF_CONTAINED_BUNDLE:BOOL=ON ../ || exit 1
make -j 3 install || exit 1
cd ..
fi



exit

mkdir -p appimage
cp /sources/appimage.sh appimage
bash appimage/appimage.sh
