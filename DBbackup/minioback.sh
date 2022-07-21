#!/bin/bash
echo hello, welcome to byos


CREATION_TIME=`date -u +"%d-%m-%Y"`

echo $CREATION_TIME

 #Spinnaker Minio Backup
 
minio=$(kubectl get po --field-selector=status.phase=Running | grep "minio" | awk '{print $1}')

echo $minio

 kubectl exec $minio -- sh -c "tar -czvf /tmp/export.gz /export"
 
 kubectl cp $minio:/tmp/export.gz /miniodump/export.gz
 
ls -ltra /miniodump/
