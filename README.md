# raspi_setup

Setup script for Raspberry pi, including scripts, configurations, etc...

Setup is optimized for Raspberry Pi Zero.

# Preparation

Prepare following configuration files in **/etc/conf.d**:

- bme280.conf:

{% codeblock /etc/conf.d/bme280.conf lang:md %}
SHEET_KEY=\<SHEET_KEY>
WORKSHEET_NAME=Living
SERVICE_ACCOUNT=/etc/conf.d/credentials.json
TIMEDELTA=9
{% endcodeblock %}

Ref: [rcmdnk/tsd2gspread: Time Series Data to Google Sheets](https://github.com/rcmdnk/tsd2gspread)

- mhz19.conf:

{% codeblock /etc/conf.d/mhz19.conf lang:md %}
SHEET_KEY=\<SHEET_KEY>
WORKSHEET_NAME=Living
SERVICE_ACCOUNT=/etc/conf.d/credentials.json
TIMEDELTA=9
{% endcodeblock %}

Ref: [rcmdnk/tsd2gspread: Time Series Data to Google Sheets](https://github.com/rcmdnk/tsd2gspread)

- credentials.json:

Ref: [Authentication — gspread 3.7.0 documentation](https://gspread.readthedocs.io/en/latest/oauth2.html#for-bots-using-service-account)

# Usage

1. Run presetup.sh
1. Prepare configuration files
1. Run install.sh
