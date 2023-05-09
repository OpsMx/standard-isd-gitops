#!/bin/bash
helm version
git --version
cd /repo/
ls -ltr
sleep 30
echo $version
#beta=$(echo $version | awk -F - '{print $NF}' | grep -c b)
if [ "$beta" = "true" ]; then
  helm repo add staging-helm https://opsmx.jfrog.io/artifactory/opsmx-helm-local
  helm repo list
  helm repo update
  helm search repo staging-helm --versions
  helm pull staging-helm/oes --version="$version"
else
helm repo add isd https://helmcharts.opsmx.com/
if [ $? != 0 ]; then
  n=0
  until [ "$n" -ge 3 ]
  do
  echo Retrying.....
  helm repo add isd https://helmcharts.opsmx.com/
  if [ $? != 0 ]; then
    echo "ERROR: Failed to add helm repo"
  else
    echo "Repo added successfully.."
    break
  fi
  n=$((n+1))
  sleep 5
  done
else
  echo "Repo added successfully.."
fi
helm repo list
helm repo update
helm search repo --versions
#chartversion=$(helm search repo isd/oes --versions | awk '{print $2,$3}' | grep "${version}" | head -1 | awk -F ' ' '{print $1}')
chartversion=$version
helm pull isd/oes --version="$chartversion"
fi
chartversion=$version
tar -xf oes-"$chartversion".tgz
if [ $? -eq 0 ]; then  
     echo "##################Sucessfully downloaded the helm chart######################"
else
   echo "##################Failed to downlaod the helm chart###################################"
   exit 1
fi
############################# special cases removing b64enc###################################################
isdver=$(echo ${version} |awk -F . '{print $1,$2}' |tr -s ' ' '.')
if [ "$isdver" == 3.9 ]; then
   sed -i 's/| *b64enc *//g' /repo/oes/charts/spinnaker/charts/minio/templates/secrets.yaml
else
   sed -i 's/| *b64enc *//g' /repo/oes/charts/minio/templates/secrets.yaml
fi
sed -i 's/| *b64enc *//g' /repo/oes/charts/redis/templates/secret.yaml
sed -i 's/| *b64enc *//g' /repo/oes/charts/openldap/templates/secret.yaml
sed -i 's/| *b64enc *//' /repo/oes/templates/sapor-gate/sapor-gate-secret.yaml
sed -i 's/^data:/stringData:/' /repo/oes/templates/sapor-gate/sapor-gate-secret.yaml
sed -i 's/{{ .Values.saporgate.config.password }}/encrypted:saporpassword:saporpassword/' /repo/oes/config/sapor-gate/gate-local.yml
####################################################################################################################
helm template isd /repo/oes/ -f values.yaml --output-dir=isd
if [ $? -eq 0 ]; then  
     echo "######################Helm template is sucessfull into isd directory###########################"
else
   echo "######################Helm template failed to isd directory########################################"
   exit 1
fi
ls -l isd/oes/
ls -l isd/oes/templates/
rm -rf /repo/isd/oes/charts/spinnaker/templates/hooks/
rm -rf /repo/isd/oes/templates/hooks/cleanup.yaml
rm -rf /repo/oes/
rm -rf oes-${chartversion}.tgz
#####################################committing tempates to github repo################################
git status
git add .
git config --global user.email "${gitemail}"
git config --global user.name "${username}"
git commit -m "Manifest file dir of helm chart for ISD ${version}"
git push
if [ $? -eq 0 ]; then  
     echo "########################Sucesfully pushed helm template to github####################################"
else
   echo "#########################Failed to pushed helm template to github###############################"
   exit 1
fi
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
#eval "value=\$$keyName"
value=$(kubectl -n $namespace  get secret $keyName -o jsonpath="{.data.$keyName}" )
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
kubectl apply -R -f /repo/isd/ -n $namespace
if [ $? -eq 0 ]; then  
     echo "##################Kubernetes manifest sucessfully applied into the $namespace########################"
else
   echo "#########################Kubernetes manifest not applied sucesfully into the $namespace################"
   exit 1
fi
