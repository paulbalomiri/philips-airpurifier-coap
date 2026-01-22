#!/usr/bin/env bash

EXTENDED_HELP=$(cat <<- EOH
Script for controlling Philips CX5120 (Philips heater series 5000) air purifier via aioairctrl.
the available actions are:
  status                     - get the current status of the device
  start|on [value]           - start the device, optional value to send as D03102 (default: 1, should not be changed)
  stop|off [value]           - stop the device, optional value to send as D03102 (default: 0, should not be changed)
  swing [on|off]             - enable or disable swing mode
  mode [vent|low|high|auto]  - set the operating mode
  set_temp|temp [1-37]      - set target temperature (1-37 degrees Celsius) and enable auto mode
  beep [on|off]             - enable or disable beep sound
EOH
)
# m4_ignore(
echo "This is just a parsing library template, not the library - pass this file to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.11.0
# ARG_OPTIONAL_SINGLE([device],[d],[The device to control],["$AIOAIR_DEVICE_IP"])
# ARG_POSITIONAL_SINGLE([action])
# ARG_POSITIONAL_SINGLE([value],["The value associated with the action"],[""])
# ARG_DEFAULTS_POS
# ARG_HELP([Script for controlling Philips CX5120 (Philips heater series 5000) air purifier via aioairctrl.],[$EXTENDED_HELP])
# ARG_VERBOSE([v], [turn on debug mode (can be supplied multiple tomes)])
# ARGBASH_GO
