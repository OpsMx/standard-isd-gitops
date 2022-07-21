#!/bin/bash
echo hello, welcome to byos

# To get the minio pod name
minio=$(kubectl get po --field-selector=status.phase=Running |grep "minio" | awk '{print $1}')
echo $minio

ls -ltra /miniodump

# To copy the front50 file to /tmp dir of minio pod
kubectl cp /miniodump/export.gz $minio:/tmp


# To unzip the copied file with in the minio pod
kubectl exec $minio -- sh -c "tar -xvf /tmp/export.gz -C /tmp/"

# To copy the extracted  data to required path of minio
kubectl exec $minio -- sh -c "cp -r /tmp/export/* /export/"
