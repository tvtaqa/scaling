#!/bin/bash
ip="http://192.168.123.186:80"
logfile="burst.txt"
query=( 4.47  4.30  4.06  3.87  4.24  4.53  4.80    5.00  4.90  5.24  
        5.92  6.63  7.00  7.75  8.37  9.22  12.25   8.37  7.75  6.71  
        7.07  7.25  6.89  6.71  6.86  8.37  6.75    6.52  6.20  7.04  
        7.00  6.63  6.32  6.12  5.92  5.70  5.79    5.48  5.24  4.47  
        4.06  4.36  4.47  4.69  4.06  3.32  3.81    3.74    )
con=( 4   4   4   4   4   5   5   5   5   5
      6   7   7   8   8   9   12  8   8   7   
      7   7   7   7   7   8   7   7   6   7   
      7   7   6   6   6   6   6   5   5   4   
      4   4   4   5   4   3   4   4  )
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

