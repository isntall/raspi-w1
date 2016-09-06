#!/bin/bash



INTERVAL=60
HEARTBEAT=120
MAXRECORD=6000000

function rrdgraph() {
  [ -f "./conf" ] && source "./conf"

  DUR=$1
  rrdtool graph w1_graph-$DUR.png \
  -w 1920 -h 1080 -a PNG  -i \
  --slope-mode \
  --start -$DUR --end now --step 60 \
  --font DEFAULT:7: \
  --title "W1 sensor $DUR" \
  --watermark "$(date)" \
  --vertical-label "TEMP(F)" \
  --alt-autoscale \
  --right-axis-format %3.2lf \
  --right-axis 1:0 \
  $(for i in "${SEN[@]}"; do \
      DCOLOR="0000FF" && DCOLOR1="0000EE" && DGRAPHELEMENT="LINE3" && DNAME=${i}; \
      [ ! -z "${NAME[$i]}" ] && DNAME=${NAME[$i]}; \
      [ ! -z "${COLOR[$i]}" ] && DCOLOR=${COLOR[$i]}; \
      [ ! -z "${GE[$i]}" ] && DGE=${GE[$i]}; \
      DRAW="$DGE:${i}avg#${DCOLOR}:${DNAME}"; \
      echo "  DEF:${i}avg=${i}.rrd:${i}:AVERAGE  DEF:${i}min=${i}.rrd:${i}:MIN DEF:${i}max=${i}.rrd:${i}:MAX $DRAW   GPRINT:${i}avg:LAST:Cur\:%5.2lf  GPRINT:${i}avg:AVERAGE:Avg\:%5.2lf  GPRINT:${i}min:MIN:Min\:%5.2lf GPRINT:${i}max:MAX:Max\:%5.2lf COMMENT:\\n " ;  \
    done)

}

W1DIR="/sys/bus/w1/devices/"
NUMM=0
DEVICEDIR=$(cd $W1DIR && ls)
if [ "graph" = "$1" ]; then
  for i in $DEVICEDIR; do
    if [[ ${i} == *"28-"* ]] 
    then
      SEN[$NUMM]="$i"
      ((NUMM++))
    fi
  done
  count=0
  DUR="3600"
  if [ ! -z $2 ]; then
    DUR=$2 # && echo "DUR=$DUR"
    rrdgraph $DUR
    cp w1_graph-$DUR.png /usr/share/nginx/html/
  else
    rrdgraph 1hour
  fi
else
  touch ./active
  for i in $DEVICEDIR; do
    if [[ ${i} == *"28-"* ]]
    then
      TEMP_RAW=$(python ./thermometer.py ${i})
      TEMPF=$(echo ${TEMP_RAW} | awk '{print $1}')
      TEMPC=$(echo ${TEMP_RAW} | awk '{print $2}')
      if [[ ! -f ./${i}.rrd ]]; then
        rrdtool create ${i}.rrd \
        --step $INTERVAL \
        DS:${i}:GAUGE:$HEARTBEAT:-68:258 \
        RRA:MIN:0.5:1:$MAXRECORD \
        RRA:MAX:0.5:1:$MAXRECORD \
        RRA:AVERAGE:0.5:1:$MAXRECORD
      fi
      rrdupdate ./${i}.rrd --template ${i} N:$TEMPF
      echo -e "$(date +%s)\t${TEMPC}\t${TEMPF}" >> ./${i}.txt
    fi
  done
  rm ./active
fi
