#!/usr/bin/env bash
set -e

PREFIX=/opt
ENABLE_SERVICE=1
PY_VER=3.13.1

if [ $# -gt 0 ];then
  if [ "$(echo "$1"|cut -d '=' -f1)" = "--prefix" ];then
    prefix_tmp="$(echo "$1"|cut -d '=' -f2)"
    if [ "$prefix_tmp" != "" ];then
      PREFIX="$prefix_tmp"
    fi
  fi
fi

cmd () {
   echo "$" "$@"
   "$@"
   ret=$?
   if [ $ret -ne 0 ];then
     exit $ret
   fi
}

top_dir=$(cd "$(dirname "$0")" && pwd)
cmd cd "$top_dir" || exit 1

mkdir -p "$PREFIX/var"

# Disable HDMI
sudo /opt/vc/bin/tvservice -o

# Update apt
cmd sudo apt update -y

# For common usage
cmd sudo apt install -y git

# For Python
if ! type python${PY_VER%.*} >/dev/null 2>&1;then
  cmd cd /tmp
  cmd wget "https://www.python.org/ftp/python/${PY_VER}/Python-${PY_VER}.tgz"
  cmd tar zxvf Python-${PY_VER}.tgz
  cmd cd Python-${PY_VER} || exit 1
  cmd ./configure
  cmd make
  cmd sudo make install
  cmd cd ../ || exit 1
  cmd rm -rf Python-${PY_VER} Python-${PY_VER}.tgz
  cmd cd "$top_dir" || exit 1
fi

# Tsd2Gspread
cmd sudo apt install libssl-dev
cmd sudo pip3 install tsd2gspread

# LCD
cmd sudo pip3 install rpi_lcd

# For BME280
# [Raspberry Piで温度湿度気圧を測ってスマホで見る](https://rcmdnk.com/blog/2019/08/26/computer-iot-raspberrypi/)
cmd sudo apt install -y libi2c-dev i2c-tools wiringpi
#cmd cd "$top_dir" || exit 1
#cmd git clone https://github.com/andreiva/raspberry-pi-bme280.git
cmd sudo pip3 install smbus2

# For MH-Z19B
cmd sudo pip3 install pyserial
cmd sudo pip3 install mh-z19

# For metrics
cmd sudo pip3 install psutil

# For Speedtest
cmd sudo pip3 install speedtest-cli

# Install executables
cmd cd "$top_dir" || exit 1
dest_bin="$PREFIX/bin"
cmd mkdir -p "$dest_bin"
for f in "$top_dir"/bin/*;do
  if [ -f "$f" ];then
    dest_file="$dest_bin/$(basename "$f")"
    cmd rm -f "$dest_file"
    cmd ln -s "$f" "$dest_file"
    cmd chmod 755 "$dest_file"
  fi
done

# Service
cmd cd "$top_dir" || exit 1
services=()
for f in ./etc/systemd/system/*;do
  if [ ! -f "$f" ];then
    continue
  fi
  dest_file=/etc/systemd/system/$(basename "$f")
  cmd sudo cp "$f" "$dest_file"
  cmd sed -i"" "s|PREFIX_BIN|$dest_bin|g" "$dest_file"
  name=$(basename "$f")
  if [ "$name" != "bme280.service" ] \
      && [ "$name" != "amedas.service" ] \
      && [ "$name" != "mhz19.service" ] \
      && [ "$name" != "metrics.service" ] \
      && [ "$name" != "check.service" ];then
    services=("${services[@]}" "$name")
  fi
done
cmd sudo systemctl daemon-reload
if [ "$ENABLE_SERVICE" -eq 1 ];then
  for s in "${services[@]}";do
    cmd sudo systemctl enable "$s"
    cmd sudo systemctl restart "$s"
  done
fi
