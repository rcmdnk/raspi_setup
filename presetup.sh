#!/usr/bin/env bash
SWAP_SIZE=2408
LOG_SIZE=1G
TIME_ZONE="Asia/Tokyo"
NEW_HOSTNAME="raspberrypizero"

cmd () {
   echo "$" "$@"
   "$@"
   ret=$?
   if [ $ret -ne 0 ];then
     exit $ret
   fi
}

# pre setup
echo "# Initial setup: reboot after setup"

# Set locale
cmd sudo raspi-config nonint do_change_locale en_US.UTF-8
cmd sudo raspi-config nonint do_change_timezone "${TIME_ZONE}"

# Update OS
cmd sudo apt -y update
cmd sudo apt -y dist-upgrade

# Change swap
cmd sudo sed -i -e "s/^CONF_SWAPSIZE=.*/CONF_SWAPSIZE=${SWAP_SIZE}/g" /etc/dphys-swapfile

# Enable I2C
cmd sudo sed -i"" "s/^.*dtparam=i2c_arm=.*$/dtparam=i2c_arm=on/" /boot/config.txt
if ! grep -q "^i2c-dev$" /etc/modules;then
  echo "$ sudo sh -c \"echo i2c-dev >> /etc/modules\""
  sudo sh -c "echo i2c-dev >> /etc/modules"
fi

# Enable UART
sudo sh -c "echo '' >> /boot/config.txt"
sudo sh -c "echo '# Enable UART' >> /boot/config.txt"
#echo "$ sudo sh -c \"echo 'enable_uart=1' >> /boot/config.txt\""
#sudo sh -c "echo 'enable_uart=1' >> /boot/config.txt"
echo "$ sudo sh -c \"echo 'dtoverlay=pi3-miniuart-bt' >> /boot/config.txt\""
sudo sh -c "echo 'dtoverlay=pi3-miniuart-bt' >> /boot/config.txt"
echo "$ sudo sh -c \"echo 'core_freq=250' >> /boot/config.txt\""
sudo sh -c "echo 'core_freq=250' >> /boot/config.txt"

# journald log size
cmd sudo sed -i -e "s/^.*SystemMaxUse=.*/SystemMaxUse=${LOG_SIZE}/g" /etc/systemd/journald.conf

# Disable X-server
#cmd sudo update-rc.d lightdm disable

# Disable GUI
#cmd sudo systemctl set-default multi-user.target
# Enable GUI
#cmd sudo systemctl set-default graphical.target

# Set Host name
cmd sudo sed -i "s/raspberrypi/${NEW_HOSTNAME}/g" /etc/hosts
cmd sudo sed -i "s/raspberrypi/${NEW_HOSTNAME}/g" /etc/hostname

# Change password
#echo 'pi:<new password>' | chpasswd

cmd sudo reboot
sleep 100
