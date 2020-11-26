#!/bin/bash
ip="http://192.168.250.84:80"
logfile="gentle.txt"
query=( 10.77 11.22 12.17 12.49 11.75 11.92 11.4  11.83 12.08 12.17
        12.17 12.33 12.08 11.75 11.83 11.66 12.17 12.08 12  11.92 
        11.83 11.83 11.92 11.75 12.08 12.25 12.65 12.41 12.17 12.08 
        12.17 12.33 11.83 11.92 11.31 11.83 12.08 12.17 12.49 10.86 11.31 11.4  
        11.83 12.08 12.17 12.88 11.75 11.92   )
con=( 11  11  12  12  12  12  11  12  12  12
      12  12  12  12  12  12  12  12  12  12  
      12  12  12  12  12  12  13  12  12  12  
      12  12  12  12  11  12  12  12  12  11  
      11  11  12  12  12  13  12  12)
count=0
#kubectl delete hpa php-apache -n test
#kubectl autoscale deployment php-apache -n test --cpu-percent=80 --min=1 --max=10
#kubectl scale --replicas=1 deploy/php-apache -n test
#kubectl set resources deployment php-apache -n test  --limits=cpu=675m --requests=cpu=675m
while [ $count -lt 48 ]
do
      command="hey -q ${query[$count]} -c ${con[$count]} -z 300s    ${ip}"
      echo "$command" >> $logfile
      echo $(date +"%Y-%m-%d %H:%M:%S") >> $logfile
      echo "`$command`" >> $logfile
      echo "-------------------------------------------------------------" >> $logfile
      let count=count+1
done



