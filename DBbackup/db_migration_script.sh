export saporusername=$(kubectl -n "$ns" get secret sapor-gate-files -o yaml | yq e '.data."gate-local.yml"' - | base64 -d | yq e '.security.user.name' -)

export saporpassword=$(kubectl -n "$ns" get secret sapor-gate-files -o yaml | yq e '.data."gate-local.yml"' - | base64 -d | yq e '.security.user.password' -)

export host=$(kubectl -n "$ns" get secret oes-platform-config -o yaml | yq e '.data."platform-local.yml"' - | base64 -d  | yq e '.spring.datasource.url' - |sed 's|://| |g' | sed 's|:| |g' | awk '{print $3}')

export port=$(kubectl -n "$ns" get secret oes-platform-config -o yaml | yq e '.data."platform-local.yml"' - | base64 -d  | yq e '.spring.datasource.url' - | grep -Eo '[0-9]{1,4}')

export username=$(kubectl -n "$ns" get secret oes-platform-config -o yaml | yq e '.data."platform-local.yml"' - | base64 -d  | yq e '.spring.datasource.username' -)

export password=$(kubectl -n "$ns" get secret oes-platform-config -o yaml | yq e '.data."platform-local.yml"' - | base64 -d  | yq e '.spring.datasource.password' -)

export password=$(kubectl -n "$ns" get secret oes-platform-config -o yaml | yq e '.data."platform-local.yml"' - | base64 -d  | yq e '.spring.datasource.password' -)

export ldappassword=$(kubectl -n "$ns" get secret ldappassword -o  yaml | yq e '.data.ldappassword' - | base64 -d )

export oesgateurl=https://$(kubectl  get  ing | grep "oes-gate" | awk '{print $3}')

export oesuiurl=https://$(kubectl  get  ing | grep "oes-ui" | awk '{print $3}')/gate

echo "export ns=$ns" > /repo/environment

echo "export host=$host" >>  /repo/environment

echo "export oesgateurl=$oesgateurl" >>  /repo/environment

echo "export oesuiurl=$oesuiurl" >>  /repo/environment

echo "export port=$port" >> /repo/environment

echo "export pguser=$username" >> /repo/environment

echo "export pgpassword=$password" >> /repo/environment

echo "export saporpassword=$saporpassword" >> /repo/environment

echo "export saporusername=$saporusername" >> /repo/environment

echo "export ldappassword=$ldappassword" >> /repo/environment

cp -r /home/opsmx/scripts/scripts/oes-data-migration-scripts/ /repo/
