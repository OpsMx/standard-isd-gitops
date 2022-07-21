#!/bin/bash
helm version
git --version
cd /repo/

echo "################Removing the job related templates##############"
rm -rf /repo/isd/oes/templates/hooks/oes-config-job.yaml
rm -rf /repo/isd/oes/templates/hooks/github-create.yaml
################################################################
echo "##########Replacing Secret#########"
grep -ir encrypted: /repo/isd/ | sort -t: -u -k1,1 |cut -d : -f1 > tmp.list
cat tmp.list | grep -v secret-decoder.yaml > tmp1.list
#######replacing with undecoded string for secrets that have data and not stringdata#########################
while read file
do
if grep ^data: $file
then
if grep ^"kind: Secret" $file
then
cat $file | grep encrypted: > secret-strings.list
while read -r secret ; do
keyName=$(echo $secret | sed 's/:/ /g' | awk -F'encrypted' '{print $2}' | awk '{print $1}')
echo secret and are $keyName
value=$(kubectl -n $namespace  get secret $keyName -o jsonpath="{.data.$keyName}" )
#eval "value=\$$keyName"
sed -i "s/encrypted:$keyName:$keyName/$value/g" $file
#echo value is $value
done < secret-strings.list
echo $file is secret and has data
fi
fi
done < tmp1.list
############################ replace secrets with decoded values stringdata or configmaps#####################################
while IFS= read -r file; do
cat $file | grep encrypted: > secret-strings.list
echo $file
cat secret-strings.list
while read -r secret ; do
keyName=$(echo $secret | sed 's/:/ /g' | awk -F'encrypted' '{print $2}' | awk '{print $1}')
echo secret and are $keyName
value=$(kubectl -n $namespace  get secret $keyName -o jsonpath="{.data.$keyName}" | base64 -d)
#eval "value=\$$keyName"
sed -i "s/encrypted:$keyName:$keyName/$value/g" $file
#echo value is $value
done < secret-strings.list
done < tmp1.list
sed -i "s/encrypted%3Agittoken%3Agittoken/$gittoken/g" isd/oes/templates/secrets/opsmx-gitops-secret.yaml
sed -i 's/yml:/yml: |/' /repo/isd/oes/templates/sapor-gate/sapor-gate-secret.yaml
kubectl get jobs -n $namespace | grep sample-app | awk '{print $1}' | xargs kubectl delete job
sleep 10s
kubectl apply -R -f /repo/isd/ -n $namespace
if [ $? -eq 0 ]; then  
     echo "#################################Kubernetes manifest sucessfully applied into the $namespace#################################"
else
   echo "#################################Kubernetes manifest not applied sucesfully into the $namespace#################################"
   exit 1
fi
