#! /bin/bash

bash /sources/build-appimage.sh || exit 1
bash /sources/package-appimage.sh || exit 1

