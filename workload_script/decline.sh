#!/bin/bash
ip="http://192.168.250.84:80"
logfile="decline.txt"
query=( 18.17 16.88 16.43 15.78 15  17.32 17.06 16.79 16.43 16.52
         16.25 16.06 15.49 15.2  15  14.49 14.8  15.1  14.39 13.96
         13.42 12.85 12.73 12.85 11.36 11.22 10.82 10.54 9.33  9.64
         10.95 11.62 9.8 9.49  9.17  8.83  7.94  6.93  7.55  7.14
          6.48  5.48  6.24  6.71  5.74  6.48  5.74  6  )
con=( 18  17  16  16  15  17  17  17  16  17  16  16  15
      15  15  14  15  15  14  14  13  13  13  13  11  11
      11  11  9   10  11  12  10  9   9   9   8   7   8
      7 6 5 6 7 6 6 6 6     )
count=0
#kubectl delete hpa php-apache -n test
#kubectl autoscale deployment php-apache -n test --cpu-percent=80 --min=1 --max=10
#kubectl scale --replicas=1 deploy/php-apache -n test
#kubectl set resources deployment php-apache -n test  --limits=cpu=675m --requests=cpu=675m
while [ $count -lt 48 ]
do
      command="hey -q ${query[$count]} -c ${con[$count]}  -z 300s    ${ip}"
      echo "$command" >> $logfile
      echo $(date +"%Y-%m-%d %H:%M:%S") >> $logfile
      echo "`$command`" >> $logfile
      echo "-------------------------------------------------------------" >> $logfile
      let count=count+1
done