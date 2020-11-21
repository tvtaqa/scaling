#!/bin/bash
ip="http://192.168.123.186:80"
logfile="burst.txt"
query=( 6.32  6.08  5.74  5.48  6 6.4 6.78  7.07  6.93  7.42  8.37
        9.38  9.9 10.95 11.83 15.65 17.46 15  10.95 9.49  10  10.25 
        9.75  9.49  9.7 11.83 9.54  9.22  8.77  9.95  9.9 9.38  
        8.94  8.66  8.37  8.06  8.19  7.75  7.42  6.32  5.74  6.16  
        6.32  6.63  5.74  4.69  5.39  5.29   )
con=( 6 6 6 5 6 6 7 7 7 7 8 9 10  11  
      12  16  17  15  11  9 10  10  10 
     9 10  12  10  9 9 10  10  9 9 9 8 8 8 8 
     7 6 6 6 6 7 6 5 5 5 )
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