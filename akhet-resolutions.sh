#!/bin/bash
/usr/bin/xrandr | grep -P ' \d{3,4}x\d{3,4} '  | awk '{ print $1 }'
