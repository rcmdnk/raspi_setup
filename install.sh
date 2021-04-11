#!/usr/bin/env bash
PREFIX=/opt
ENABLE_SERVICE=1
if [ $# -gt 0 ];then
  if [ "$(echo $1|cut -d '=' -f1)" = "--prefix" ];then
    prefix_tmp="$(echo $1|cut -d '=' -f2)"
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

# For common usage
cmd sudo apt install -y git

# Tsd2Gspread
cmd sudo pip3 install tsd2gspread

# For BME280
# [Raspberry Piで温度湿度気圧を測ってスマホで見る](https://rcmdnk.com/blog/2019/08/26/computer-iot-raspberrypi/)
cmd cd "$top_dir" || exit 1
cmd sudo apt install -y libi2c-dev i2c-tools wiringpi
#cmd git clone https://github.com/andreiva/raspberry-pi-bme280.git
cmd sudo pip3 install smbus2

# For MH-Z19B
cmd sudo pip3 install pyserial
cmd sudo pip3 install mh-z19

# For metrics
cmd sudo pip3 install psutil

# For COCORO
cmd sudo pip3 install cocoro

# For Blynk
# [Blynkを使ってRaspberryi Piをスマホから操作する](https://rcmdnk.com/blog/2019/08/18/computer-iot-raspberrypi/)
cmd cd "$top_dir" || exit 1
#cmd git clone https://github.com/blynkkk/blynk-library.git
#cmd cd blynk-library/linux
cd submodules/blynk-library/linux || exit 1
cmd make clean all target=raspberry

# Install executables
cmd cd "$top_dir" || exit 1
dest_bin="$PREFIX/bin"
cmd mkdir -p "$dest_bin"
for f in "$top_dir"/bin/*;do
  if [ -f "$f" ];then
    dest_file="$dest_bin/$(basename "$f")"
    cmd rm -f "$dest_file"
    cmd ln -s $f "$dest_file"
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
      && [ "$name" != "mhz19.service" ] \
      && [ "$name" != "metrics.service" ];then
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
