#!/bin/bash
echo hello, welcome to byos


CREATION_TIME=`date -u +"%d-%m-%Y"`

echo $CREATION_TIME


# To get the redis pod
redis=$(kubectl get po | grep "redis" | awk '{print $1}')
echo $redis

  # To Update the redis configMap
#redis_cm=$(kubectl get cm |  grep -m  1 "redis"| awk '{print $1}')

  # To update the "appendonly no" to "appendonly yes" in the redis configMap
#kubectl get cm $redis_cm -o yaml | sed 's/appendonly no/appendonly yes/g' | kubectl replace -f -

kubectl cp $redis:/data/dump.rdb /redisdump/redisdata_dump.rdb
#kubectl cp $redis:/data/appendonly.aof /redisdump/redisdata_appendonly.aof > /dev/null 2>&1 
 
 tar -cvf /redisdump/redis_backup.tar /redisdump/redisdata_*

 ls -ltra /redisdump/
