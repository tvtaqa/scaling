#!/bin/bash
ip="http://192.168.250.84:80"
logfile="seasonal.txt"
query=( 4.47  4.9 5.48  6.32  8.37  8 8.94  10.95 11.83 10.49 10
        8.94  9.33  8.77  7.75  7.07  4.47  4.9 5.48  6.32  8.37  
        8 8.94  10.95 12.65 10.49 10  8.94  8.94  8.77  7.75  7.07  
        4.47  4.9 5.48  6.32  8.37  8 8.94  10.95 13.42 10.49 10  
        8.94  9.33  8.77  7.75  7.07   )
con=( 4   5   5   6   8   8   9   11  12  10  10  9   
      9   9   8   7   4   5   5   6   8   8   9   11  
      13  10  10  9   9   9   8   7   4   5   5   6   
      8   8   9   11  13  10  10  9   9   9   8   7 )
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




