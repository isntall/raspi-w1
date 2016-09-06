#!/bin/bash
#set -uex
[ -f "./conf" ] && source "./conf"

W1DIR="/sys/bus/w1/devices/"
NUMM=0
DEVICEDIR=$(cd $W1DIR && ls | grep '28-')

if [ "logro" = "$1" ]; then
  while [  -f "./active" ]; do
    sleep 5;
  done
  for i in $DEVICEDIR; do
    j=${i/-/_}
    mv ./${i}.txt /tmp/${j}.txt.$(date +%s)
  done
elif [ "dump" = "$1" ]; then
  rsync -A /tmp/*.txt.* ser@nuc5:/tmp/
  ssh ser@nuc5 "bash -c 'mysqlimport ${dbCreds}  --use-threads=3 -h 127.0.0.1 w1 --local /tmp/*.txt.*'"
  ssh ser@nuc5 "bash -c 'rm /tmp/*.txt.*'"
  rm /tmp/*.txt.*
fi
