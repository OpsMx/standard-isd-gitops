# ISD Installation Instructions
## Create your git-repo
*ISD stores all the configuration in a repo, typically a 'git repo', though bitbucket, S3 and others are supported.*

1. Create an empty-repo (called the "gitops-repo"),  "main" branch should be the defauly, and clone it locally
2. Clone https://github.com/OpsMx/standard-isd-gitops, selecting the appropriate branch. E.g:
   git clone https://github.com/OpsMx/  -b 3.12
3. Copy contents of the standard-isd-repo to the gitops-repo created above using:
   
   `cp -r standard-isd-gitops/* gitops-repo`
   
   and cd to the gitops-repo e.g. `cd gitops-repo`

## Specify inputs based on your environment and git-repo
*The installation process requires inputs such as the application version, git-repo details and so on.*

4. In the gitops-repo cloned to disk and edit install/inputcm.yaml. This should be updated with version of ISD, gitrepo and user details.
5. Update Values.yaml as required, specifically, the ISD URL, SSO and gitops repo. 
NOTE: We recommend that we start with the defaults, updating just the URL and gitopsHalyard details and gradually adding SSO, external DBs, etc. while updating the installed instance

6. Push all changes in the gitops-repo to git (e.g `git add -A; git commit -m"my changes";git push`)

7. Create a configmap for inputs and a service account as follows:
- `kubectl -n opsmx-isd apply -f install/inputcm.yaml` 
- `kubectl -n opsmx-isd apply -f install/serviceaccount.yaml`

## Create secrets
*ISD supports multiple secret managers for storing secrets such as DB passwords, SSO authenticatoin details and so on. Using kubernetes secrets is the default*

8. Create the following secrets. The default values are provided, except for gittoken. If you are using External SSO, DBs, etc. you might want to change them. Else, best to leave them at the defaults:
- `kubectl -n opsmx-isd create secret generic gittoken --from-literal=gittoken=`**PUT_YOUR_GITTOKEN_HERE**

- `kubectl -n opsmx-isd create secret generic ldapconfigpassword --from-literal ldapconfigpassword=opsmxadmin123`
- `kubectl -n opsmx-isd create secret generic ldappassword --from-literal ldappassword=opsmxadmin123`
- `kubectl -n opsmx-isd create secret generic miniopassword --from-literal miniopassword=spinnakeradmin`
- `kubectl -n opsmx-isd create secret generic redispassword --from-literal redispassword=password`
- `kubectl -n opsmx-isd create secret generic saporpassword --from-literal saporpassword=saporadmin`
- `kubectl -n opsmx-isd create secret generic dbpassword --from-literal dbpassword=networks123`
- `kubectl -n opsmx-isd create secret generic rabbitmqpassword --from-literal rabbitmqpassword=Networks123`
- `kubectl -n opsmx-isd create secret generic keystorepassword --from-literal keystorepassword=changeit`

## Start the installation
*The installation is done by a kubenetes job that processes the secrets, generates YAMLs, stores them into the git-repo and creats the objectes in Kubernetes.*

9. Installation ISD by executing this command:

- `kubectl -n opsmx-isd apply -f install/ISD-Install-Job.yaml`

## Monitor the installation process
10. Wait for all pods to stabilize (about 10-20 min, depending on your cluster load). Check status using:

- `kubectl -n opsmx-isd get po -w`

**NOTE-1**: If the pod starting with isd-install-* errors out, please check the logs as follows, replacing the pod-name correctly:
- `kubectl -n opsmx-isd logs isd-install-tjzlx -c get-secrets`
- `kubectl -n opsmx-isd logs isd-install-tjzlx -c git-clone`
- `kubectl -n opsmx-isd logs isd-install-tjzlx -c apply-yamls`


**NOTE-2**: It is normal for some pods, specifically oes-ui pod to crash a few times before running. However, if isd-spinnaker-halyard-0 pod crashes or errors out, please check the logs of the "create-halyard-local" init container using this command:
- `kubectl -n opsmx-isd logs isd-spinnaker-halyard-0 -c create-halyard-local`

## Check the installation
11. Access ISD using the URL specified in the values.yaml in step 5 in a browser such as Chrome.




