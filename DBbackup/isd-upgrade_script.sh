export gittoken=`kubectl -n "$namespace" get secret gittoken -o yaml | yq e '.data.gittoken' - | base64 -d`

export ldappassword=`kubectl -n "$namespace" get secret ldappassword -o yaml | yq e '.data.ldappassword' - | base64 -d`

export dbpassword=`kubectl -n "$namespace" get secret dbpassword -o yaml | yq e '.data.dbpassword' - | base64 -d`

export keystorepassword=`kubectl -n "$namespace" get secret keystorepassword -o yaml | yq e '.data.keystorepassword' - | base64 -d`

export rabbitmqpassword=`kubectl -n "$namespace" get secret rabbitmqpassword -o yaml | yq e '.data.rabbitmqpassword' - | base64 -d`

export saporpassword=`kubectl -n "$namespace" get secret saporpassword -o yaml | yq e '.data.saporpassword' - | base64 -d`

export redispassword=`kubectl -n "$namespace" get secret redispassword -o yaml | yq e '.data.redispassword' - | base64 -d`

export miniopassword=`kubectl -n "$namespace" get secret miniopassword -o yaml | yq e '.data.miniopassword' - | base64 -d`

export ldapconfigpassword=`kubectl -n "$namespace" get secret ldapconfigpassword -o yaml | yq e '.data.ldapconfigpassword' - | base64 -d`


git clone https://"$username":"$gittoken"@"$url" -b "$branch" /repo

echo "export namespace=$namespace" > /repo/environment

echo "export gittoken=$gittoken" >> /repo/environment

echo "export ldappassword=$ldappassword" >>  /repo/environment

echo "export dbpassword=$dbpassword" >> /repo/environment

echo "export keystorepassword=$keystorepassword" >> /repo/environment

echo "export rabbitmqpassword=$rabbitmqpassword" >> /repo/environment

echo "export saporpassword=$saporpassword" >> /repo/environment

echo "export redispassword=$redispassword" >> /repo/environment

echo "export miniopassword=$miniopassword" >>  /repo/environment

echo "export ldapconfigpassword=$ldapconfigpassword" >> /repo/environment
