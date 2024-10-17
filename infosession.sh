#!/bin/bash

procesos = "$(ps -e -o sid,pgid,pid,user,tty,%mem,cmd --no-headers --sort=user  | awk '{print $1 " " $2 " " $3 " " $4 " " $5 " " $6 " " $7 " "}') "
