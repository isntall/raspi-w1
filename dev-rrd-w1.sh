#!/bin/bash



INTERVAL=60
HEARTBEAT=120
MAXRECORD=6000000

function rrdgraph() {
  [ -f "./conf" ] && source "./conf"

  DUR=$1
  rrdtool graph w1_graph-$DUR.png \
  -w 1280 -h 720 -a PNG  -i \
  --slope-mode \
  --start -$DUR --end now --step 60 \
  --font DEFAULT:7: \
  --title "W1 sensor $DUR" \
  --watermark "$(date)" \
  --vertical-label "TEMP(F)" \
  --alt-autoscale \
  --right-axis 1:0 \
  $(for i in "${SEN[@]}"; do \
      DCOLOR="0000FF" && DCOLOR1="0000EE" && DGRAPHELEMENT="LINE3" && DNAME=${i}; \
      [ ! -z "${NAME[$i]}" ] && DNAME=${NAME[$i]}; \
      [ ! -z "${COLOR[$i]}" ] && DCOLOR=${COLOR[$i]}; \
      [ ! -z "${GE[$i]}" ] && DGE=${GE[$i]}; \
      DRAW="$DGE:${i}avg#${DCOLOR}:${DNAME}avg  VDEF:${i}vmax=${i}max,MAXIMUM HRULE:${i}vmax#000000 VDEF:${i}vmin=${i}max,MINIMUM HRULE:${i}vmin#000000 "; \
      echo "  DEF:${i}avg=${i}.rrd:${i}:AVERAGE  DEF:${i}min=${i}.rrd:${i}:MIN  DEF:${i}max=${i}.rrd:${i}:MAX $DRAW   GPRINT:${i}avg:LAST:Cur\:%5.2lf  GPRINT:${i}avg:AVERAGE:Avg\:%5.2lf  GPRINT:${i}min:MIN:Min\:%5.2lf GPRINT:${i}max:MAX:Max\:%5.2lf COMMENT:\\n " ;  \
    done)
#echo "  DEF:${i}avg=${i}.rrd:${i}:AVERAGE  DEF:${i}min=${i}.rrd:${i}:MIN  $DRAW   GPRINT:${i}avg:LAST:Cur\:%5.2lf  GPRINT:${i}avg:AVERAGE:Avg\:%5.2lf  GPRINT:${i}avg:MIN:Min\:%5.2lf GPRINT:${i}avg:MAX:Max\:%5.2lf COMMENT:\\n " ;  \
#DEF:${i}min=${i}.rrd:${i}:MIN VDEF:${i}vmin=${i}min,MIN HRULE:${i}vmin#000000 
  cp w1_graph-$DUR.png /var/www/html/
}

W1DIR="/sys/bus/w1/devices/"
NUMM=0
DEVICEDIR=$(cd $W1DIR && ls | grep '28-')
if [ "graph" = "$1" ]; then
  for i in $DEVICEDIR; do
    SEN[$NUMM]="$i"
    ((NUMM++))
  done
  count=0
  DUR="3600"
  if [ ! -z $2 ]; then
    DUR=$2 # && echo "DUR=$DUR"
    rrdgraph $DUR
  else
    rrdgraph 1hour
  fi
else
  for i in $DEVICEDIR; do
    TEMPC_RAW=$(cat $W1DIR/$i/w1_slave | grep 't=' | awk -F= '{print $2}')
    TEMPC=$(echo "scale=4; $TEMPC_RAW/1000" | bc)
    TEMPF=$(echo "scale=4; ($TEMPC*(9.0/5.0))+32.0" | bc)
    if [[ ! -f ./${i}.rrd ]]; then
      rrdtool create ${i}.rrd \
      --step $INTERVAL \
      DS:${i}:GAUGE:$HEARTBEAT:-68:258 \
      RRA:MIN:0.5:1:$MAXRECORD \
      RRA:MAX:0.5:1:$MAXRECORD \
      RRA:AVERAGE:0.5:1:$MAXRECORD
    fi
    rrdupdate ./${i}.rrd --template ${i} N:$TEMPF
  done
#  date
fi
