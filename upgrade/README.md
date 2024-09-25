
# Upgrade Instructions

Please follow these instructions to upgrade ISD to 2024.06.00. The current installation (or we call it the 'fromVersion') could have been installed using helm (Scenario A) or using the gitops installer (Scenario B). Please follow the steps as per your current scenario.

**Note**: ISD can be upgraded to 2024.06.00 from version 4.0.3.1 or later versions. Please pay attention to the DB Upgrade requirement for specific upgrade paths.

**WARNING**: Please backup all the databases, in particualr the Postgres DB, BEFORE begining the upgrade. Backup procedures may differ depending your usage of external DBs and Spinnaker configuration. 

## Scenario A
Use these instructions if:
- You have ISD installed using the helm installer and
- Already have a "gitops-repo" for Spinnaker Configuration
- Have values.yaml that was used for helm installation

Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**https://github.com/.../gitops-repo**
- `git clone https://github.com/OpsMx/standard-isd-gitops.git -b 2024.06.00`
- `cp standard-isd-gitops/default/profiles/echo-local.yml gitops-repo/default/profiles/`
- `cp -r standard-isd-gitops/upgrade gitops-repo`
- `cd gitops-repo`
- Copy the existing "values.yaml", that was used for previous installation into this folder. Let us call it values-fromVersion.yaml
- Update the values-fromVersion.yaml as per the requirement
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
Use this set of instructions if:
a) You have ISD installed using gitops installer
b) Already have a gitops-repo for ISD (AP and Spinnaker) Configuration

Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**https://github.com/.../gitops-repo**
- `git clone https://github.com/OpsMx/standard-isd-gitops.git -b 2024.06.00`
- `cp -r standard-isd-gitops/upgrade gitops-repo/` 
- `cd gitops-repo`
- Check that a "values.yaml" file exists in this directory (root of the gitops-repo)

## Common Steps
Upgrade sequence:
1. Ensure that "default" account is configured to deploy to the ISD namespace (e.g. opsmx-isd)
2. If you have modified "sampleapp" or "opsmx-gitops" applications, please backup them by using the "syncToGit" pipeline opsmx-gitops application.
3. Copy the bom from standard-isd-gitops.git to the gitops-repo

   `cp -r standard-isd-gitops/bom gitops-repo/`

4. If there are any custom settings done for spinnaker please update those changes accordingly in gitops-repo/default/profiles.

5. `cd upgrade`
6. Update upgrade-inputcm.yaml: 
   - url, username and gitemail MUST be updated. TIP: if you have install/inputcm.yaml from previous installation, simply copy-paste these lines here.
   - **If ISD Namespace is different from "opsmx-isd"**: Update namespace (default is opsmx-isd) to the namespace where ISD is installed
7. **If ISD Namespace is different from "opsmx-isd"**: Edit serviceaccount.yaml and edit "namespace:" to update it to the ISD namespace (e.g.oes)
8. Update values.yaml:

   - Set `autoInstallSampleApps` to false
   - (Optional) Refer to [this](https://docs.google.com/document/d/1FgbvGeylTmWKBFKZNs2mMkKlkxHpyzPMEy5wJCaKSxk/edit) document if you want to enable the new Insights pages (Pipeline Insights and User Insights) added to ISD.
   - **DB Upgrade**:
   
       Set the `dbmigration enabled` flag to 
	   - `true`, if you are upgrading ISD from a version older than 4.0.4.1 (e.g. 4.0.3.1) 
	   - `false`, if you are upgrading ISD from 4.0.4.1 or a newer version.
        
	   If `dbmigration enaled` is set to true, set the `dbmigration versionFrom` property to the ISD version in numeric (e.g. 4.0.3.1 or 4.0.4.2 or 4.0.4.3 ) you are currently running. 
	   
	   Sample configuration for upgrade from ISD 4.0.3.1  
       ```
       dbmigration:
         enable: true
         versionFrom: 4.0.3.1 ## We need to update this flag if we want to run migration from other ISD versions. For eg: versionFrom: 4.0.3.1
       ```
	   
       Sample configuration for upgrade from ISD 4.0.4.2 
       ```
       dbmigration:
         enable: false
         versionFrom: 4.0.4.2 ## We need to update this flag if we want to run migration from other ISD versions. For eg: versionFrom: 4.0.3.1
       ```	   
9. Push changes to git: `git add -A; git commit -m "Upgrade related changes"; git push`
10. `kubectl -n opsmx-isd apply -f upgrade-inputcm.yaml`
11. `kubectl patch configmap/upgrade-inputcm --type merge -p '{"data":{"release":"isd"}}' -n opsmx-isd` # Default release name is "isd".
     Please update it accordingly and apply the command

12. `kubectl -n opsmx-isd apply -f serviceaccount.yaml` # Edit namespace if changed from the default "

13. `kubectl -n opsmx-isd replace --force -f ISD-Generate-yamls-job.yaml`
   [ Wait for isd-generate-yamls-* pod to complete ]

    - Once the pod is completed please check the pod logs to verify manifest files are updated in GIt or not.

      `kubectl -n opsmx-isd logs isd-generate-yamls-xxx -c git-clone` #Replacing the name of the pod name correctly, check if your gitops-repo is cloned correctly

14. Compare and merge branch: This job should have created a branch on the gitops-repo with the helmchart version number specified in upgrade-inputcm.yaml. Raise a PR and check what changes are being made. Once satisfied, merge the PR.

15. `kubectl -n opsmx-isd replace --force -f ISD-Apply-yamls-job.yaml`
   Wait for isd-yaml-update-* pod to complete
    
    - Once pod will completed so please check the pod logs to verify manifest files are updated in Git or not.

      `kubectl -n opsmx-isd logs isd-apply-yamls-xxx -c git-clone` #Replacing the name of the pod name correctly, check if your gitops-repo is cloned correctly

      `kubectl -n opsmx-isd logs isd-apply-yamls-xxx -c script` #Replacing the name of the pod name correctly, check the log of the script that pushes the yamls and applies them

16. Add the below configuration (if not already present) in the default/profiles/echo-local.yml for echo pods.
     ```
       ssd:
         name: preview-saas-ssd
         enable: false
       ```    
17. isd-spinnaker-halyard-0 pod should restart automatically. If not, execute this:
   
      - `kubectl -n opsmx-isd  delete po isd-spinnaker-halyard-0`

18. Restart all pods:
      - `kubectl -n opsmx-isd scale deploy -l app=oes --replicas=0` Wait for a min or two
      - `kubectl -n opsmx-isd scale deploy -l app=oes --replicas=1` Wait for all pods to come to ready state
        
19. If you enabled new Insights feature in step 8, please follow the post installation steps listed [here](https://docs.google.com/document/d/1FgbvGeylTmWKBFKZNs2mMkKlkxHpyzPMEy5wJCaKSxk/edit#heading=h.odfvfs38x0e3)
 
20. Go to ISD UI and check that version number has changed in the top right corner (under Help menu)

21. Wait for about 5 min for autoconfiguration to take place.

22. If required: a) Connect Spinnaker again b) Configure pipeline-promotion again. To do this, in the ISD UI:
      - Click setup
      - Click Spinnaker tab at the top. Check if "External Accounts" and "Pipeline-promotion" columns show "yes". If any of them is "no":
      - Click "edit" on the 3 dots on the far right. Check the values already filled in, make changes if required and click "update".
      - Restart the halyard pod by clicking "Sync Accounts to Spinnaker" in the Cloud Accounts tab or simply delete the halyard pod

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
