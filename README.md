# raspi_setup

Setup script for Raspberry pi, including scripts, configurations, etc...

Setup is optimized for Raspberry Pi Zero.

# Preparation

Prepare configuration files in **/etc/conf.d** like config.example.

And prepare the following files in **/etc/conf.d**:

- credentials.json:

Ref: [Authentication — gspread 3.7.0 documentation](https://gspread.readthedocs.io/en/latest/oauth2.html#for-bots-using-service-account)

# Usage

1. Run presetup.sh
1. Prepare configuration files
1. Run install.sh
