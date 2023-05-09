# ISD Installation Instructions

## Infrastructure and Laptop requirements
- Infrastructure requires for a non-prod installation can be found [here](https://docs.google.com/document/d/1nIJ__SWrh3iJIE7mKot5QuiE7dSkrB2m9uPYHg-h8CI/edit?usp=sharing)
- Infrastructure requires for a Production Setup can be found [here](https://docs.google.com/document/d/127q5y5ROr_Mb17hdOOz9eP_CuFxrH56R4qlplnCbsMA/edit?usp=sharing)
- Basic requirements of a laptop and kubenetes cluster can be found [here](https://docs.google.com/document/d/1SeQ53Ve3xHA9nBBf7C47_Qk4tcd4qxzyq4w2gFMAq28/edit#heading=h.gaiml9joopel).

Should we have different infrastructure requirements, please contact OpsMx.

## Create your git-repo
*ISD stores all the configuration in a repo, typically a 'git repo', though bitbucket, S3 and others are supported.*

1. Create an empty-repo (called the "gitops-repo" in the document),  "main" branch should be the default, and clone it locally
2. Clone https://github.com/OpsMx/standard-isd-gitops, selecting the appropriate branch:
- `git clone https://github.com/OpsMx/standard-isd-gitops  -b 4.0.3.1`

3. Copy contents of the standard-isd-repo to the gitops-repo created above using:
   
   `cp -r standard-isd-gitops/* gitops-repo` # Replace "gitops-repo" with your repo-name
   
   and cd to the gitops-repo e.g. `cd gitops-repo`

## Specify inputs based on your environment and git-repo
*The installation process requires inputs such as the application version, git-repo details and so on.*

4. In the gitops-repo cloned to disk and edit `install/inputcm.yaml`. This should be updated, at a **minimum**, with gitrepo and username.
5. **Update Values.yaml as required**, specifically: At **minimum** the ISD URL and gitops-repo details in spinnaker.gitopsHalyard section must be updated. Full values.yaml is available at: https://github.com/OpsMx/enterprise-spinnaker/tree/v4.0.3/charts/oes

NOTE: We recommend that we start with the defaults, updating just the URL and gitopsHalyard details and gradually adding SSO, external DBs, etc. while updating the installed instance.

6. Edit namespace in the `install/inputcm.yaml` file and `install/serviceaccount.yaml`,  if changed from default (i.e. "opsmx-isd")
7. Push all changes in the gitops-repo to git (e.g `git add -A; git commit -m"my changes";git push`)
8. Create namespace, a configmap for inputs and a service account as follows [edit namespace (i.e. opsmx-isd) as appropriate]:
- `kubectl create ns opsmx-isd` 
- `kubectl -n opsmx-isd apply -f install/inputcm.yaml` 
- `kubectl -n opsmx-isd apply -f install/serviceaccount.yaml`

## Create secrets
*ISD supports multiple secret managers for storing secrets such as DB passwords, SSO authenticatoin details and so on. Using kubernetes secrets is the default.*

9. Create the following secrets. The default values are handled by the installer, except for gittoken. If you are using External SSO, DBs, etc. you might want to change them. Else, best to leave them at the defaults:
- `kubectl -n opsmx-isd create secret generic gittoken --from-literal=gittoken=PUT_YOUR_GITTOKEN_HERE`

### Optional
*In case we want to change these, please enter the correct values and create the secrets*

- `kubectl -n opsmx-isd create secret generic ldapconfigpassword --from-literal ldapconfigpassword=PUT_YOUR_SECRET_HERE`
- `kubectl -n opsmx-isd create secret generic ldappassword --from-literal ldappassword=PUT_YOUR_SECRET_HERE`
- `kubectl -n opsmx-isd create secret generic miniopassword --from-literal miniopassword=PUT_YOUR_SECRET_HERE`
- `kubectl -n opsmx-isd create secret generic redispassword --from-literal redispassword=PUT_YOUR_SECRET_HERE`
- `kubectl -n opsmx-isd create secret generic saporpassword --from-literal saporpassword=PUT_YOUR_SECRET_HERE`
- `kubectl -n opsmx-isd create secret generic rabbitmqpassword --from-literal rabbitmqpassword=PUT_YOUR_SECRET_HERE`
- `kubectl -n opsmx-isd create secret generic keystorepassword --from-literal keystorepassword=PUT_YOUR_SECRET_HERE`

## Start the installation
*The installation is done by a kubenetes job that processes the secrets, generates YAMLs, stores them into the git-repo and creats the objectes in Kubernetes.*

10. Installation ISD by executing this command:

- `kubectl -n opsmx-isd apply -f install/ISD-Install-Job.yaml`

## Monitor the installation process
11. Wait for all pods to stabilize (about 10-20 min, depending on your cluster load). The "oes-config" in Completed status indicates completion of the installation process. Check status using:

- `kubectl -n opsmx-isd get po -w`

**NOTE-1**: If the pod starting with isd-install-* errors out, please check the logs as follows, replacing the pod-name correctly:
- `kubectl -n opsmx-isd logs isd-install-tjzlx -c get-secrets`
- `kubectl -n opsmx-isd logs isd-install-tjzlx -c git-clone`
- `kubectl -n opsmx-isd logs isd-install-tjzlx -c apply-yamls`


**NOTE-2**: It is normal for some pods, specifically oes-ui pod to crash a few times before running. However, if isd-spinnaker-halyard-0 pod crashes or errors out, please check the logs of the "create-halyard-local" init container using this command:
- `kubectl -n opsmx-isd logs isd-spinnaker-halyard-0 -c create-halyard-local`

## Check the installation
12. Access ISD using the URL specified in the values.yaml in step 5 in a browser such as Chrome.
13. Login to the ISD instance with user/password as admin and opsmxadmin123, if using the defaults for build-in LDAP.

## Switch from OpenLDAP to Saml
1. Document to update from OpenLDAP to Saml can be found [here](https://docs.google.com/document/d/1y1xpMFq5fm5oqS83Bk62msM9VzdIr5kAcH_j2sNrmCw/edit#)
2. Inorder to Install/Upgrade user can use saml-values.yaml file.
   - Move the old values.yaml to openldap-values.yaml and saml-values.yaml to values.yaml

   **NOTE**: Make sure values.yaml has saml configuration

# Troubleshooting Issues during installation
## ISD-Install-Job fails to start, no pod created or it errors
Execute this command:
- `kubectl -n opsmx-isd describe job isd-install`

## Some of the pods are not coming up
Check the logs of the isd-install-xxxx pod with the following command
- `kubectl -n opsmx-isd logs isd-install-xxx -c git-clone` #Replacing the name of the pod name correctly, check if your gitops-repo is cloned correctly
- `kubectl -n opsmx-isd logs isd-install-xxx` #Replacing the name of the pod name correctly, check the log of the script that pushes the yamls and applies them

## ISD not working, e.g UI not reachable
Most common issues during installation are related to incorrect values in values.yaml. Should you realize that there is a mistake, it is easy to correct it.
- Update the values.yaml, and push to the git-repo
- Wait for the helm install to error out, it is best to not break the process
- `kubectl -n opsmx-isd apply -f install/ISD-Install-Job.yaml`
- Once the job is in Completed state, if required, delete the crashing/erroring pods and the isd-spinnaker-halyard-0 pod

## *-spinnaker-halyard-0 is in error/crashloop
One of the common errors faced by first time installers is spinnaker-halyard going into an Error state. Most common reason is that the init container failed to clone the gitops repo. Note that “main” branch is expected to be the default branch for the repo.

Use the following command (replace isd below with the helm release-name) to check if the git clone is happening:

- `kubectl -n opsmx-isd logs isd-spinnaker-halyard-0 -c create-halyard-local`

If the clone is not happening correctly, please check your values.yaml git user, token, repo, branch etc. For those interested, the script can be found in the isd-spinnaker-halyard-init-script

## Only clouddriver and igor pods are in error/crashloop
This is usually caused by incorrect "branch". Ensure that the "default" label in default/profiles/spinnakerconfig.yml is "main" or whatever branch you are using. Once corrected, restart the halyard pod by deleting it e.g.:
- `kubectl -n opsmx-isd delete po isd-spinnaker-halyard-0`


# Cleaning up/Delete the installation

Issue these commands, replace -n option with the namespace 
- `kubectl -n opsmx-isd delete deploy --all`
- `kubectl -n opsmx-isd delete sts --all`
- `kubectl -n opsmx-isd delete svc --all`
- `kubectl -n opsmx-isd delete ing --all`
- `kubectl -n opsmx-isd delete cm --all`
- `kubectl -n opsmx-isd delete jobs  --all` 
- `kubectl -n opsmx-isd delete pvc -–all`
- `kubectl -n opsmx-isd delete secrets --all`
- `kubectl delete ns opsmx-isd`


