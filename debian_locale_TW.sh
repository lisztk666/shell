#!/bin/bash
export LC_ALL="en_US.UTF-8"
sudo sed -i '/^#.* zh_TW.* /s/^#//' /etc/locale.gen
sudo locale-gen
sudo update-locale LANG="zh_TW.UTF-8" LANGUAGE="zh_TW"
echo "Please re-login or restart your system!"
