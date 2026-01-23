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

Using --restriction-to-beep-disabled option, only executes the action if the beep is disabled.
This makes it possible to turn off the device automation using this script by enabling the beep. The script will then not intervene on top of user automation.
The actions 'status' and 'beep' are exempted from this restriction and will always be executed, regardless of the --restriction-to-beep-disabled optoin.
--restriction-to-beep-disabled needs the jq (JSON processor) command line tool to be installed.


Supplying --no-restriction-to-pingable will send commands regardless of whether the device is pingable or not.
By default, the script will only send commands if the device is pingable.

Use -v to increase verbosity, can be supplied multiple times for more verbosity. supplyiong it one time
logs major steps and restriction statuses, supplying it twice logs the actual aioairctrl commands that are executed.

EOH
)
# m4_ignore(
echo "This is just a parsing library template, not the library - pass this file to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.11.0
# ARG_OPTIONAL_SINGLE([device],[d],[The device to control],["$AIOAIR_DEVICE_IP"])
# ARG_POSITIONAL_SINGLE([action])
# ARG_POSITIONAL_SINGLE([value],["The value associated with the action"],[""])
# ARG_OPTIONAL_BOOLEAN([restriction-to-beep-disabled],[B],[Restrict actions and only act if beep is disabled],[off])
# ARG_OPTIONAL_BOOLEAN([restriction-to-pingable],[],[Restrict actions and only act if ],[on])

# ARG_DEFAULTS_POS
# ARG_HELP([Script for controlling Philips CX5120 (Philips heater series 5000) air purifier via aioairctrl.],[$EXTENDED_HELP])
# ARG_VERBOSE([v], [turn on debug mode (can be supplied multiple tomes)])
# ARGBASH_GO
