#!/bin/bash
ip="http://192.168.123.186:80"
logfile="rise.txt"
query=( 2.24  2.65  3.16  2.83  3.46  3.87  4.24  4.00  4.36  4.69
        5.00  5.20  4.90  5.39  5.66  6.24  5.20  4.47  4.58  6.00
        6.32  6.48  7.00  6.71  6.93  7.14  7.35  7.21  7.75  7.87  
        8.19  8.43  8.31  8.54  8.83  8.94  9.17  8.94  8.77  9.22  
        9.54  9.80  10.15   9.43  9.33  9.27  9.38  9.49    )
con=(  2  3   3   3   3   4   4   4   4   5
       5  5   5   5   6   6   5   4   5   6
       6  6   7   7   7   7   7   7   8   8
       8  8   8   9   9   9   9   9   9   9
       10 10  10  9   9   9   9   9    )
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
