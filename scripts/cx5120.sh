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


aio_args=( aioairctrl --host $_arg_device)
case $_arg_action in
  status)
    [ "$_arg_verbose" -ge 1 ] && echo "Getting status"
    aio_args+=( status )
    ;;
  start|on)
    [ -n "$_arg_value" ] || _arg_value=1
    [ "$_arg_verbose" -ge 1 ] && echo "Starting device"
    aio_args+=( set D03102=${_arg_value} -I )
    ;;
  stop|off)
    [ -n "$_arg_value" ] || _arg_value=0
    [ "$_arg_verbose" -ge 1 ] && echo "Stopping device"
    aio_args+=( set D03102=${_arg_value} -I )
    ;;
  swing)
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
[ "$_arg_verbose" -ge 1 ] &&  echo ${aio_args[@]}
${aio_args[@]}

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^
