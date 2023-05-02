#!/bin/bash
helm version
git --version
cd /repo/
ls -ltr
sleep 30
echo $version
#beta=$(echo $chartVersion | awk -F - '{print $NF}' | grep -c b)
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
#chartVersion=$(helm search repo isd/oes --versions | awk '{print $2,$3}' | grep "${version}" | head -1 | awk -F ' ' '{print $1}')
#version=$chartVersion
helm pull isd/oes --version="$version"
fi
#version=$chartVersion
tar -xf oes-"$version".tgz
if [ $? -eq 0 ]; then  
     echo "#################################Sucessfully downloaded the helm chart#################################"
else
   echo "#################################Failed to downlaod the helm chart#################################"
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
helm template ${release} /repo/oes/ -f values.yaml --output-dir=/tmp/isd
if [ $? -eq 0 ]; then  
     echo "#################################Helm template is sucessfull into isd directory#################################"
else
   echo "#################################Helm template failed to isd directory#################################"
   exit 1
fi
ls -l /tmp/isd/oes/
ls -l /tmp/isd/oes/templates/
rm -rf /tmp/isd/oes/charts/spinnaker/templates/hooks/
rm -rf /tmp/isd/oes/templates/hooks/cleanup.yaml
rm -rf /repo/oes/
rm -rf oes-"$version".tgz
#####################################committing tempates to github repo################################
git branch "$version"
if [ $? -eq 0 ]; then  
     echo "#################################Sucesfully created a branch in github#################################"
else
   echo "#################################Failed to created a branch in github#################################"
   exit 1
fi
git checkout "$version"
git rm -rf /repo/isd/
cp -r /tmp/isd/ /repo/
git status
git add .
git config --global user.email "${gitemail}"
git config --global user.name "${username}"
git commit -m "Manifest file dir of helm chart with ISD ${version}"
git push origin "$version" --force
if [ $? -eq 0 ]; then  
     echo "#################################Sucesfully pushed helm template to github#################################"
else
   echo "#################################Failed to pushed helm template to github#################################"
   exit 1
fi
