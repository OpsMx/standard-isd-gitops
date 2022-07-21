#!/bin/bash
echo hello, welcome to byos

# To get the redis pod
redis=$(kubectl get po | grep "redis" | awk '{print $1}')

# To get the redis configMap
#redis_cm=$(kubectl get cm | grep -m  1 "redis"| awk '{print $1}')

    # To Update the redis configMap
# To update the "appendonly no" to "appendonly yes" in the redis configMap
#kubectl get cm $redis_cm -o yaml | sed 's/appendonly no/appendonly yes/g' | kubectl replace -f -

    tar -xf /redisdump/redis_backup.tar -C /tmp/

     # To copy the /tmp/dump.rdb to redis
    # kubectl cp  /tmp/redisdump/appendonly.aof $redis:/data/appendonly.aof 



    #kubectl cp  /tmp/redis_dump.rdb $redis:/data/appendonly.aof
    kubectl cp  /tmp/redisdump/redis_dump.rdb $redis:/data/dump.rdb


# To Delete the redis pod
kubectl delete po $redis
