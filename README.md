# raspi-w1

This project uses the w1 sensors on a Raspberry Pi v1.
(It should probably work on newer Raspberry Pi's)

## Hardware
* Raspberry Pi B
* 10K Resistor
* Proto board
* Jumper wires
* Digital Temperature Temp Sensor Probe DS18b20 (http://amzn.com/B00KUNKR3M)

## Dependencies
* 2016-05-27-raspbian-jessie-lite
* rrdtool (note: due to the design of rrd, the rrd files are arm specific)
* nginx


```
  # apt-get install rrdtool nginx
  # echo 'dtoverlay=w1-gpio' >> /boot/config.txt
```
add to crontab
```
  * * * * *      cd /home/pi/w1-oneminute-avg && ./rrd-w1.sh && sleep 20 && ./rrd-w1.sh && sleep 20 && ./rrd-w1.sh
  * * * * *      cd /home/pi/w1-oneminute-avg && ./db-w1.sh && sleep 20 && ./db-w1.sh && sleep 20 && ./db-w1.sh
```

TODO: Save script and data in ```/usr/local```

## Useful links

https://learn.adafruit.com/adafruits-raspberry-pi-lesson-11-ds18b20-temperature-sensing/ds18b20
