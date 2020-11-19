#!/bin/bash
ip="http://192.168.250.84:80"
logfile="gentle.txt"
query=( 7.62  7.94  8.60  8.83  8.31  8.43   8.06  8.37  8.54  8.60
        8.60  8.72  8.54  8.31  8.37  8.25   8.60  8.54  8.49  8.43
        8.37  8.37  8.43  8.31  8.54  8.66   8.94  8.77  8.60  8.54  
        8.60  8.72  8.37  8.43  8.00  8.37   8.54  8.60  8.83  7.68  
        8.00  8.06  8.37  8.54  8.60  9.11   8.31  8.43  )
con=( 8     8     9     9     8     8     8     8     9     9
      9     9     9     8     8     8     9     9     8     8
      8     8     8     8     9     9     9     9     9     9
      9     9     8     8     8     8     9     9     9     8
      8     8     8     9     9     9     8     8 )
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
