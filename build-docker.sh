#! /bin/bash

#BABL_GIT_TAG=BABL_0_1_56
#GEGL_GIT_TAG=GEGL_0_4_8
#GIMP_GIT_TAG=GIMP_2_10_6

IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
xhost + $IP



docker run --rm -it -e DISPLAY=${IP}:0 -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd):/sources centos:7 bash 
#docker run --rm -it -v $(pwd):/sources photoflow/docker-centos7-gtk bash 
#/sources/ci/appimage-centos7.sh

