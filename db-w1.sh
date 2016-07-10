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
    mv ${j}.txt /tmp/${j}.txt.$(date +%s)
  done
elif [ "dump" = "$1" ]; then
  rsync -A /tmp/*.txt.* ser@nuc5:/tmp/
  ssh ser@nuc5 "mysqlimport ${dbCreds}  --use-threads=3 -h 127.0.0.1 w1 --local /tmp/*.txt.*"
  ssh ser@nuc5 "rm /tmp/*.txt.*"
  rm /tmp/*.txt.*
else
  touch ./active
  for i in $DEVICEDIR; do
    j=${i/-/_}
    TEMPC_RAW=$(cat $W1DIR/${i}/w1_slave | grep 't=' | awk -F= '{print $2}')
    TEMPC=$(echo "scale=4; $TEMPC_RAW/1000" | bc)
    TEMPF=$(echo "scale=4; ($TEMPC*(9.0/5.0))+32.0" | bc)
    echo -e "$(date +%s)\t${TEMPC}\t${TEMPF}" >> ${j}.txt
  done
  rm ./active
fi
