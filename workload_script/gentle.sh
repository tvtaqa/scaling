#!/bin/bash
ip="http://192.168.250.84:80"
logfile="gentle.txt"
query=( 10.49   9.75  9.49  9.11  8.66  10.00   9.85  9.70  9.49  9.54
        9.38    9.27  8.94  8.77  8.66  8.37    8.54  8.72  8.31  8.06  
        7.75    7.42  7.35  7.42  6.56  6.48    6.24  6.08  5.39  5.57  
        6.32    6.71  5.66  5.48  5.29  5.10    4.58  4.00  4.36  4.12  
        3.74    3.16  3.61  3.87  3.32  3.74    3.32  3.46   )
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
