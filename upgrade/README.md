
# Upgrade Instructions

Please follow these instructions if you are upgrading from 3.12 (to 4.0.3). The current installtion (3.12) could have been installed using helm (Scenario A) or using the gitops installer (Scenario B). Please follow the steps as per your current scenario.

**WARNING**: Please backup all the databases, in particualr the Posgres DB, BEFORE begining the upgrade. Backup procedures may differ depending your usage of external DBs and Spinnaker configuration. 

## Scenario A
Use these instructions if:
- You have a 3.12.x installed using the helm installer and
- Already have a "gitops-repo" for Spinnaker Configuration
- Have values.yaml that was used for helm installation

Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**https://github.com/.../gitops-repo**
- `git clone https://github.com/OpsMx/standard-isd-gitops.git -b 4.0.3`
- `cp -r standard-isd-gitops/upgrade gitops-repo`  
- `cd gitops-repo`
- Copy the existing "values.yaml", that was used for previous installation into this folder. We will call it values-312.yaml
- diff values-402.yaml values-312.yaml and merge all of your changes into "values.yaml". **NOTE**: In most cases just replacing images v3.12.x with v4.0.3 is enough.
- Copy the updated values file as "values.yaml" (file name is important)
- create gittoken secret. This token will be used to authenticate to the gitops-repo
   - `kubectl -n opsmx-isd create secret generic gittoken --from-literal gittoken=PUT_YOUR_GITTOKEN_HERE` 
- create secrets mentioned above. **NOTE**: You only need to create these secrets if they are changed from the default
   - `kubectl -n opsmx-isd create secret generic ldapconfigpassword --from-literal ldapconfigpassword=PUT_YOUR_SECRET_HERE`
   - `kubectl -n opsmx-isd create secret generic ldappassword --from-literal ldappassword=PUT_YOUR_SECRET_HERE`
   - `kubectl -n opsmx-isd create secret generic miniopassword --from-literal miniopassword=PUT_YOUR_SECRET_HERE`
   - `kubectl -n opsmx-isd create secret generic redispassword --from-literal redispassword=PUT_YOUR_SECRET_HERE`
   - `kubectl -n opsmx-isd create secret generic saporpassword --from-literal saporpassword=PUT_YOUR_SECRET_HERE`
   - `kubectl -n opsmx-isd create secret generic rabbitmqpassword --from-literal rabbitmqpassword=PUT_YOUR_SECRET_HERE`
   - `kubectl -n opsmx-isd create secret generic keystorepassword --from-literal keystorepassword=PUT_YOUR_SECRET_HERE`

## Scenario B
Use this set if instructions if:
a) You have a 3.12 installed using gitops installer
b) Already have a gitops-repo for ISD (AP and Spinnaker) Configuration

Execute these commands, replacing "gitops-repo" with your repo
Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**https://github.com/.../gitops-repo**
- `git clone https://github.com/OpsMx/standard-isd-gitops.git -b 4.0.3`
- `cp -r standard-isd-gitops/upgrade gitops-repo/` 
- `cd gitops-repo`
- Check that a "values.yaml" file exists in this directory (root of the gitops-repo)

## Common Steps
Upgrade sequence: (3.12 to 4.0.3)
1. Ensure that "default" account is configured to deploy to the ISD namespace (e.g. opsmx-isd)
2. If you have modified "sampleapp" or "opsmx-gitops" applications, please backup them up using "syncToGit" pipeline opsmx-gitops application.
3. Copy the bom from standard-isd-gitops.git to the gitops-repo

   `cp -r standard-isd-gitops/bom gitops-repo/`

4. If there are any custom settings done for spinnaker please update those changes accordingly in gitops-repo/default/profiles.

5. Please refer below doc to check the differences from 3.12 to 4.0.3 of git-repo and updated it accordingly
   https://docs.google.com/document/d/14pEUXDwWshpUPRPLykM0lW4gzHvw5kHJyTJHveGlfoo/edit#
6. `cd upgrade`
7. Update upgrade-inputcm.yaml: 
   - url, username and gitemail MUST be updated. TIP: if you have install/inputcm.yaml from previous installation, simply copy-paste these lines here
   - **If ISD Namespace is different from "opsmx-isd"**: Update namespace (default is opsmx-isd) to the namespace where ISD is installed
   - If you are external Mysql for Spinnaker update the spinnakerStorage value to "sql".
8. **If ISD Namespace is different from "opsmx-isd"**: Edit serviceaccount.yaml and edit "namespace:" to update it to the ISD namespace (e.g.oes)
9. Push changes to git: `git add -A; git commit -m"Upgrade related changes";git push`
10. `kubectl -n opsmx-isd apply -f upgrade-inputcm.yaml`
11. `kubectl -n opsmx-isd apply -f serviceaccount.yaml` # Edit namespace if changed from the default "opsmx-isd"
12. `kubectl -n opsmx-isd create secret generic mysqlcredentials --from-literal host=PUT_YOUR_MYSQL_HOST_NAME --from-literal username=PUT_YOUR_MYSQL_USER_NAME --from-literal password=PUT_YOUR_MYSQL_PASSWORD` (NOTE: Do not change the default values)

13. **DB Upgrade - Schema update**: This can be be executed as a kubenetes job
   
      - `kubectl -n opsmx-isd apply -f ISD-Pre-Helm-job.yaml`   # Edit namespace if changed from the default "opsmx-isd"
      -  Once the above command is executed a new pod will be created so please check the pod logs to verify if the Schema is updated or not.
        
         **message indicating success** - "Successfully updated databases" 
        
         **message indicating failure** - "Exception occurred while updating databases"
         
         `kubectl -n opsmx-isd logs isd-pre-helm-migrate-xxx`  #Replacing the name of the pod name correctly 

      -  Use below command to scale down the services
 
         `kubectl -n opsmx-isd scale deploy oes-audit-client oes-audit-service oes-autopilot oes-dashboard oes-datascience oes-platform oes-sapor oes-visibility --replicas=0`

14. `kubectl -n opsmx-isd replace --force -f ISD-Generate-yamls-job.yaml`
   [ Wait for isd-generate-yamls-* pod to complete ]

    - Once the pod is completed please check the pod logs to verify manifest files are updated in GIt or not.

         `kubectl -n opsmx-isd logs isd-generate-yamls-xxx -c git-clone` #Replacing the name of the pod name correctly, check if your gitops-repo is cloned correctly

15. Compare and merge branch: This job should have created a branch on the gitops-repo with the helmchart version number specified in upgrade-inputcm.yaml. Raise a PR and check what changes are being made. Once satisfied, merge the PR.

16. `kubectl -n opsmx-isd replace --force -f ISD-Apply-yamls-job.yaml`
   Wait for isd-yaml-update-* pod to complete
    
    - Once pod will completed so please check the pod logs to verify manifest files are updated in Git or not.

      `kubectl -n opsmx-isd logs isd-apply-yamls-xxx -c git-clone` #Replacing the name of the pod name correctly, check if your gitops-repo is cloned correctly

      `kubectl -n opsmx-isd logs isd-apply-yamls-xxx -c script` #Replacing the name of the pod name correctly, check the log of the script that pushes the yamls and applies them

17. isd-spinnaker-halyard-0 pod should restart automatically. If not, execute this:
   
      - `kubectl -n opsmx-isd  delete po isd-spinnaker-halyard-0`

18. Restart all pods:
      - `kubectl -n opsmx-isd scale deploy -l app=oes --replicas=0` Wait for a min or two
      - `kubectl -n opsmx-isd scale deploy -l app=oes --replicas=1` Wait for all pods to come to ready state
 
19. Go to ISD UI and check that version number has changed in the bottom-left corner
20. Wait for about 5 min for autoconfiguration to take place.
21. If required: a) Connect Spinnaker again b) Configure pipeline-promotion again. To do this, in the ISD UI:
      - Click setup
      - Click Spinnaker tab at the top. Check if "External Accounts" and "Pipeline-promotion" columns show "yes". If any of them is "no":
      - Click "edit" on the 3 dots on the far right. Check the values already filled in, make changes if required and click "update".
      - Restart the halyard pod by clicking "Sync Accounts to Spinnaker" in the Cloud Accounts tab or simply delete the halayard pod

22. **DB Upgrade - Data update**

    This can be be executed as a kubenetes job

      - `kubectl -n opsmx-isd apply -f ISD-Post-Helm-job.yaml`   # Edit namespace if changed from the default "opsmx-isd"

      - Once the above command is executed a new pod will be created so please check the pod logs to verify if the Schema is updated or not.
        
        **message indicating success** - "Successfully updated databases"

        **message indicating failure** - "Exception occurred while updating databases"
         
        `kubectl -n opsmx-isd logs isd-post-helm-migrate-xxx`  #Replacing the name of the pod name correctly


## If things go wrong during upgrade
*As we have a gitops installer, recovering from a failed install/upgrade is very easy. In summary, we simply delete all objects are re-apply. Please follow the steps below to recover.*

As a first step. Please try the "Troubleshooting Issues during Installation" section in the Installation document.

### Reinstall ISD
[Make changes to uppgrade-inputcm and/or values.yaml as required. **Ensure that the changes are pushed to git**]
1. `kubectl -n opsmx-isd  delete sts isd-spinnaker-halyard`
2. `kubectl -n opsmx-isd  delete deploy --all`
3. `kubectl -n opsmx-isd delete svc --all`
4. `kubectl -n opsmx-isd replace --force -f ISD-Apply-yamls-job.yaml`
5.  Wait for all the pods to come up

