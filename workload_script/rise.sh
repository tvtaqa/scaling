#!/bin/bash
ip="http://192.168.123.186:80"
logfile="rise.txt"
query=( 3.87  4.58  5.48  4.9   6   6.71  7.35  6.93  7.55  8.12
        8.66  9     8.49  9.33  9.8 10.82 9     7.75  7.94  10.39 
        10.95 11.22 12.12 11.62 12  12.37 12.73 12.49 13.42 13.64 
        14.18 14.59 14.39 14.8  15.3  15.49 15.87 15.49 15.2  
        15.97 16.52 16.97 17.58 16.34 16.16 16.06 16.25 16.43   )
con=(  4  5   5   5   6   7   7     7   8   8
       9  9   8   9   10  11  9     8   8   10  
       11 11  12  12  12  12  13  12  13  14
      14  15  14  15  15  15  16  15  15  16
        17  17  18  16  16  16  16  16    )
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

3.87 
4.58 
5.48 
4.90 
6.00 
6.71 
7.35 
6.93 
7.55 
8.12 
8.66 
9.00 
8.49 
9.33 
9.80 
10.82 
9.00 
7.75 
7.94 
10.39 
10.95 
11.22 
12.12 
11.62 
12.00 
12.37 
12.73 
12.49 
13.42 
13.64 
14.18 
14.59 
14.39 
14.80 
15.30 
15.49 
15.87 
15.49 
15.20 
15.97 
16.52 
16.97 
17.58 
16.34 
16.16 
16.06 
16.25 
16.43 
