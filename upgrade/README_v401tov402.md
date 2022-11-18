
# Upgrade Instructions

 Please follow these instructions if you are upgrading from 4.0.1 (to 4.0.2). The current installtion (4.0.1) could have been installed using helm (Scenario A) or using the gitops installer (Scenario B). Please follow the steps as per your current scenario.

**WARNING**: Please backup all the databases, in particualr the Posgres DB, BEFORE begining the upgrade. Backup procedures may differ depending your usage of external DBs and Spinnaker configuration. 

## Scenario A
Use these instructions if:
- You have a 4.0.1 installed using the helm installer and
- Already have a "gitops-repo" for Spinnaker Configuration
- Have values.yaml that was used for helm installation

Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**https://github.com/.../gitops-repo**
- `git clone https://github.com/OpsMx/standard-isd-gitops.git -b 4.0`
- `cp -r standard-isd-gitops/upgrade gitops-repo`  
- `cd gitops-repo`
- Copy the existing "values.yaml", that was used for previous installation into this folder. We will call it values-401.yaml
- diff values-401.yaml values-402.yaml and merge all of your changes into "values.yaml". **NOTE**: In most cases just replacing images v4.0.1 with v4.0.2 is enough.
- Copy the updated values file as "values.yaml" (file name is important)
- create gittoken secret. This token will be used to authenticate to the gitops-repo
   - `kubectl -n oes create secret generic gittoken --from-literal gittoken=PUT_YOUR_GITTOKEN_HERE` 
- create secrets mentioned above. **NOTE**: You only need to create these secrets if they are changed from the default
   - `kubectl -n oes create secret generic ldapconfigpassword --from-literal ldapconfigpassword=PUT_YOUR_SECRET_HERE`
   - `kubectl -n oes create secret generic ldappassword --from-literal ldappassword=PUT_YOUR_SECRET_HERE`
   - `kubectl -n oes create secret generic miniopassword --from-literal miniopassword=PUT_YOUR_SECRET_HERE`
   - `kubectl -n oes create secret generic redispassword --from-literal redispassword=PUT_YOUR_SECRET_HERE`
   - `kubectl -n oes create secret generic saporpassword --from-literal saporpassword=PUT_YOUR_SECRET_HERE`
   - `kubectl -n oes create secret generic rabbitmqpassword --from-literal rabbitmqpassword=PUT_YOUR_SECRET_HERE`
   - `kubectl -n oes create secret generic keystorepassword --from-literal keystorepassword=PUT_YOUR_SECRET_HERE`

## Scenario B
Use this set if instructions if:
a) You have a 4.0.1 installed using gitops installer
b) Already have a gitops-repo for ISD (AP and Spinnaker) Configuration

Execute these commands, replacing "gitops-repo" with your repo
Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**https://github.com/.../gitops-repo**
- `git clone https://github.com/OpsMx/standard-isd-gitops.git -b 4.0`
- `cp -r standard-isd-gitops.git/upgrade gitops-repo/` 
- `cd gitops-repo`
- Check that a "values.yaml" file exists in this directory (root of the gitops-repo)

## Common Steps
Upgrade sequence: (4.0.1 to 4.0.2)
1. Ensure that "default" account is configured to deploy to the ISD namespace (e.g. oes)
2. If you have modified "sampleapp" or "opsmx-gitops" applications, please backup them up using "syncToGit" pipeline opsmx-gitops application.
3. Update the halyard version in config file i.e deploymentConfigurations.version 1.28.1
4. If there are any custom settings done for spinnaker please update those changes accordingly in gitops-repo/default/profiles and gitops-repo/default/service-settings.
5. In the gitops-repo/default/profiles in echo-local.yml file need to be updated as shown in repo https://github.com/OpsMx/standard-gitops-repo/blob/v4.0/default/profiles/echo-local.yml
6. If there are no custom settings for spinnaker please execute below commands
   - `cp -r standard-isd-gitops.git/default gitops-repo/`
7. `cd upgrade`
8. Update upgrade-inputcm.yaml: 
   - url, username and gitemail MUST be updated. TIP: if you have install/inputcm.yaml from previous installation, simply copy-paste these lines here
   - **If ISD Namespace is different from "opsmx-isd"**: Update namespace (default is opsmx-isd) to the namespace where ISD is installed
9. **If ISD Namespace is different from "opsmx-isd"**: Edit serviceaccount.yaml and edit "namespace:" to update it to the ISD namespace (e.g.oes)
10. Push changes to git: `git add -A; git commit -m"Upgrade related changes";git push`
11. `kubectl -n opsmx-isd apply -f upgrade-inputcm.yaml`
12. `kubectl -n opsmx-isd apply -f serviceaccount.yaml` # Edit namespace if changed from the default "opsmx-isd"
     
13. `kubectl -n opsmx-isd replace --force -f ISD-Generate-yamls-job.yaml`
   [ Wait for isd-generate-yamls-* pod to complete ]

14. Compare and merge branch: This job should have created a branch on the gitops-repo with the helmchart version number specified in upgrade-inputcm.yaml. Raise a PR and check what changes are being made. Once satisfied, merge the PR.

15 isd-spinnaker-halyard-0 pod should restart automatically. If not, execute this: `kubectl -n opsmx-isd  delete po isd-spinnaker-halyard-0`

16. Restart all pods:
   - `kubectl -n opsmx-isd scale deploy -l app=oes --replicas=0` Wait for a min or two
   - `kubectl -n opsmx-isd scale deploy -l app=oes --replicas=1` Wait for all pods to come to ready state
 
17. Go to ISD UI and check that version number has changed in the bottom-left corner
18. Wait for about 5 min for autoconfiguration to take place.
19. If required: a) Connect Spinnaker again b) Configure pipeline-promotion again. To do this, in the ISD UI:
   - Click setup
   - Click Spinnaker tab at the top. Check if "External Accounts" and "Pipeline-promotion" columns show "yes". If any of them is "no":
   - Click "edit" on the 3 dots on the far right. Check the values already filled in, make changes if required and click "update".
   - Restart the halyard pod by clicking "Sync Accounts to Spinnaker" in the Cloud Accounts tab or simply delete the halayard pod

## If things go wrong during upgrade
*As we have a gitops installer, recovering from a failed install/upgrade is very easy. In summary, we simply delete all objects are re-apply. Please follow the steps below to recover.*

As a first step. Please try the "Troubleshooting Issues during Installation" section in the Installation document.

### Reinstall ISD
[Make changes to uppgrade-inputcm and/or values.yaml as required. **Ensure that the changes are pushed to git**]
1. `kubectl -n oes  delete sts isd-spinnaker-halyard`
2. `kubectl -n oes  delete deploy --all`
3. `kubectl -n oes delete svc --all`
4. `kubectl -n oes replace --force -f ISD-Apply-yamls-job.yaml`
5.  Wait for all the pods to come up

