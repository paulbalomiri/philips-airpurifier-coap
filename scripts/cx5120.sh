#!/usr/bin/env bash

# Created by argbash-init v2.11.0
# Run 'argbash --strip user-content "args/cx5120-parsing.m4" -o "args/cx5120-parsing.sh"' to generate the 'args/cx5120-parsing.sh' file.
# If you need to make changes later, edit 'args/cx5120-parsing.sh' directly, and regenerate by running
# 'argbash --strip user-content "args/cx5120-parsing.sh" -o "args/cx5120-parsing.sh"'
script_dir="$(cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd)"
. "${script_dir}/args/cx5120-parsing.sh" || { echo "Couldn't find 'args/cx5120-parsing.sh' parsing library in the '$script_dir' directory" >&2; exit 1; }

# vvv  PLACE YOUR CODE HERE  vvv
# For example:
[ "$_arg_verbose" -ge 2 ] && {
    printf "Value of '%s': %s\\n" 'device' "$_arg_device"
    printf "Value of '%s': %s\\n" 'action' "$_arg_action"
    printf "Value of '%s': %s\\n" 'value' "$_arg_value"
}

[ -z "$_arg_device" ] && die "Device IP is required. Set AIOAIR_DEVICE_IP env or -d command line option" 1

function get_status() {
  aioairctrl --host "$_arg_device" status -J
}
function resolve_setting() {
  local setting_name="$1"
  case $setting_name in
    D03102|power)
      echo "D03102"
      ;;
    D03108|mode)
      echo "D03108"
      ;;
    D0310C|fan_level)
      echo "D0310C"
      ;;
    D0310E|target_temperature|temperature|temp)
      echo "D0310E"
      ;;
    D0320F|swing)
      echo "D0320F"
      ;;
    D03130|beep)
      echo "D03130"
      ;;
    D01S03|device_name|name)
      echo "D01S03"
      ;;
    *)
      echo "$setting_name"
      ;;
  esac
}
function typeof_setting() {
  local setting_name="$1"
  case $setting_name in
    D01S03|device_name|name|ProductId|DeviceId|WifiVersion|StatusType|ConnectionType|D01S05|D01S04)
      echo "str"
      ;;
    *)
      echo "int"
      ;;
  esac
}

function run_command() {
  aio_args=( aioairctrl --host $_arg_device)
  local _arg_action="${_arg_action_with_args[0]}"
  _arg_action_with_args=( "${_arg_action_with_args[@]:1}" )
  case $_arg_action in
    status)
      [ "$_arg_verbose" -ge 1 ] && echo "Getting status"
      status=${status:-$(get_status)}
      aio_args=( echo "${status}" )
      ;;
    start|on)
      [ "$_arg_verbose" -ge 1 ] && echo "Starting device"
      aio_args+=( set D03102=1 -I )
      ;;
    stop|off)
      [ "$_arg_verbose" -ge 1 ] && echo "Stopping device"
      aio_args+=( set D03102=0 -I )
      ;;
    set)
      local set_count=0
      set -f # avoid globbing (expansion of *)
      local key_value=(${_arg_action_with_args[0]//"="/ })
      local type=$(typeof_setting ${key_value[0]})
      while [[ "${#key_value[@]}" -eq 2 ]]; do
        if [[ "$set_count" -eq 0 ]]; then 
          aio_args+=( set )
          [ "$type" = "int" ] && aio_args+=( -I ) 
        elif ! [ "$type" == $(typeof_setting "${key_value[0]}") ]; then
          # type changed, stop processing, let the processing continue in 
          # next run_command call 
          _arg_action_with_args=( set "${_arg_action_with_args[@]}" )
          break;
        fi
        ((set_count++))
        
        aio_args+=( "$(resolve_setting ${key_value[0]})=${key_value[1]}" )
        _arg_action_with_args=( "${_arg_action_with_args[@]:1}" )
        key_value=(${_arg_action_with_args[0]//"="/ })
      done
      set +f # turn globbing back on
      ;;
    swing)
      local _arg_value="${_arg_action_with_args[0]}"
      _arg_action_with_args=( "${_arg_action_with_args[@]:1}" )
      case $_arg_value in
        on|1|true|yes|enable*|start)
          [ "$_arg_verbose" -ge 1 ] && echo "Setting swing to: $_arg_value"
          aio_args+=( set D0320F=17222  -I)
          ;;
        *)
          [ "$_arg_verbose" -ge 1 ] && echo "Setting swing to: $_arg_value"
          aio_args+=(set D0320F=17920  -I)
          ;;
      esac
      ;;
    beep)
      local _arg_value="${_arg_action_with_args[0]}"
      _arg_action_with_args=( "${_arg_action_with_args[@]:1}" )
      
      case $_arg_value in
        on|1|true|yes|enable*|start)
          [ "$_arg_verbose" -ge 1 ] && echo "Enabling beep"
          aio_args+=( set D03130=100  -I)
          ;;
        *)
          [ "$_arg_verbose" -ge 1 ] && echo "Disabling beep"
          aio_args+=(set D03130=0  -I)
          ;;
      esac
      ;;
    mode)
      local _arg_value="${_arg_action_with_args[0]}"
      _arg_action_with_args=( "${_arg_action_with_args[@]:1}" )
      case $_arg_value in
        0|off|vent*)
          [ "$_arg_verbose" -ge 1 ] && echo "Setting mode to ventilator"
          aio_args+=( set D03108=-127 -I )
          ;;
        1|low)
          [ "$_arg_verbose" -ge 1 ] && echo "Setting fan level to LOW"
          aio_args+=( set D0310C=66 -I )
          ;;
        2|high)
          [ "$_arg_verbose" -ge 1 ] && echo "Setting fan level to HIGH"
          aio_args+=( set D0310C=65 -I )
          ;;
        3|auto)
          [ "$_arg_verbose" -ge 1 ] && echo "Setting mode to AUTO"
          aio_args+=( set D0310C=0 -I )
          ;;
      esac
      ;;
    set_temp|temp*)
      local $_arg_value="${_arg_action_with_args[0]}"
      _arg_action_with_args=( "${_arg_action_with_args[@]:1}" )
      if ! ([[ "$_arg_value" =~ ^[0-9]+$ ]] && [ "$_arg_value" -ge "1" ] && [ "$_arg_value" -le "37" ]); then
        die "Temperature value must be an integer between 1 anf 37, got: $_arg_value" 1
      fi
      [ "$_arg_verbose" -ge 1 ] && echo "Setting target temperature to: $_arg_value, auto mode on"
      aio_args+=( set D0310E=${_arg_value} -I )
      ;;
    *)
      echo "Unknown action: $_arg_action" >&2
      exit 1
      ;;
  esac
  [ "$_arg_verbose" -ge 2 ] &&  echo ${aio_args[@]}
  ${aio_args[@]}
}

if [ "$_arg_restriction_to_pingable" = "on" ]; then
  if ! ping -c 1 -W 1 "$_arg_device" &> /dev/null; then
    [ "$_arg_verbose" -ge 1 ] && echo "Device $_arg_device is not pingable, skipping action $_arg_action"
    exit 0
  else
    [ "$_arg_verbose" -ge 1 ] && echo "Device $_arg_device is pingable, proceeding with action $_arg_action"
  fi
fi

if [ "$_arg_restriction_to_beep_disabled" = "on" ] && [ "${_arg_action}" != "status" ] && [ "${_arg_action}" != "beep" ]; then
  status=$(get_status)
  beep_status=$(echo "$status" | jq -r '.D03130')
  if [ "$beep_status" != "0" ]; then
    [ "$_arg_verbose" -ge 1 ] && echo "Beep is enabled (D03130=$beep_status), skipping action $_arg_action"
    exit 0
  else
    [ "$_arg_verbose" -ge 1 ] && echo "Beep is disabled (D03130=$beep_status), proceeding with action $_arg_action"
  fi
fi
while [ "${#_arg_action_with_args[@]}" -gt 0 ]; do
  # run_command consumes first action and its arguments from _arg_action_with_args array
  run_command
done


# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^
