#!/bin/bash


W1DIR="/sys/bus/w1/devices/"
NUMM=0
DEVICEDIR=$(cd $W1DIR && ls)
for i in $DEVICEDIR; do
  if [[ ${i} == *"28-"* ]] 
  then
    TEMP_RAW=$(python ./thermometer.py ${i})
    TEMPF=$(echo ${TEMP_RAW} | awk '{print $1}')
    TEMPC=$(echo ${TEMP_RAW} | awk '{print $2}')
    echo -e "$(date +%s)\t${TEMPF}\t${TEMPC}" >> ./${i}-rep.txt
    echo -e "$(date +%s)\t${TEMPF}\t${TEMPC}"
  fi
done

unset W1DIR
unset NUMM
unset DEVICEDIR
