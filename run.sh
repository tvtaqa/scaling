#!/bin/bash
logfile="commandline_log.txt"
command="python3 adaptive.py"

cd rise
echo "`$command`" >> $logfile
cd ..
sleep 600

cd decline
echo "`$command`" >> $logfile
cd ..
sleep 600

cd burst
echo "`$command`" >> $logfile
cd ..
sleep 600