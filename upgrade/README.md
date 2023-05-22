
# Upgrade Instructions

Please follow these instructions if you are upgrading from 4.0.3 (to 4.0.3.1). The current installtion (4.0.3) could have been installed using helm (Scenario A) or using the gitops installer (Scenario B). Please follow the steps as per your current scenario.

**WARNING**: Please backup all the databases, in particualr the Posgres DB, BEFORE begining the upgrade. Backup procedures may differ depending your usage of external DBs and Spinnaker configuration. 

## Scenario A
Use these instructions if:
- You have a 4.0.3 installed using the helm installer and
- Already have a "gitops-repo" for Spinnaker Configuration
- Have values.yaml that was used for helm installation

Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**https://github.com/.../gitops-repo**
- `git clone https://github.com/OpsMx/standard-isd-gitops.git -b 4.0.3.1`
- `cp -r standard-isd-gitops/upgrade gitops-repo`
- `cd gitops-repo`
- Copy the existing "values.yaml", that was used for previous installation into this folder. We will call it values-403.yaml
- diff values-4031.yaml values-403.yaml and merge all of your changes into "values.yaml".
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
a) You have a 4.0.3 installed using gitops installer
b) Already have a gitops-repo for ISD (AP and Spinnaker) Configuration

Execute these commands, replacing "gitops-repo" with your repo
Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**https://github.com/.../gitops-repo**
- `git clone https://github.com/OpsMx/standard-isd-gitops.git -b 4.0.3.1`
- `cp -r standard-isd-gitops/upgrade gitops-repo/` 
- `cd gitops-repo`
- Check that a "values.yaml" file exists in this directory (root of the gitops-repo)

## Common Steps
Upgrade sequence: (4.0.3 to 4.0.3.1)
1. Ensure that "default" account is configured to deploy to the ISD namespace (e.g. opsmx-isd)
2. If you have modified "sampleapp" or "opsmx-gitops" applications, please backup them up using "syncToGit" pipeline opsmx-gitops application.
3. Copy the bom from standard-isd-gitops.git to the gitops-repo

   `cp -r standard-isd-gitops/bom gitops-repo/`

4. If there are any custom settings done for spinnaker please update those changes accordingly in gitops-repo/default/profiles.

5. `cd upgrade`
6. Update upgrade-inputcm.yaml: 
   - url, username and gitemail MUST be updated. TIP: if you have install/inputcm.yaml from previous installation, simply copy-paste these lines here
   - **If ISD Namespace is different from "opsmx-isd"**: Update namespace (default is opsmx-isd) to the namespace where ISD is installed
7. **If ISD Namespace is different from "opsmx-isd"**: Edit serviceaccount.yaml and edit "namespace:" to update it to the ISD namespace (e.g.oes)
8. Push changes to git: `git add -A; git commit -m"Upgrade related changes";git push`
9. `kubectl -n opsmx-isd apply -f upgrade-inputcm.yaml`

     `kubectl patch configmap/upgrade-inputcm --type merge -p '{"data":{"release":"isd"}}' -n opsmx-isd` # Default release name is "isd". Please update it accordingly and apply the command
10. `kubectl -n opsmx-isd apply -f serviceaccount.yaml` # Edit namespace if changed from the default "opsmx-isd"

11. **DB Upgrade - Schema update**:

    Read the comments in the audit-local.yml and update the `DBHOSTNAME,DBUSERNAME,DBPASSWORD`.

    **Hint**: 
    - `DBHOSTNAME,DBUSERNAME` is passed in values.yaml under db section. Please copy paste that.
    - `DBPASSWORD` can be fetched from dbpassword secret from the Cluster.

      `kubectl -n opsmx-isd create secret generic oes-audit-service-config-new --from-file=audit-local.yml`

      `kubectl -n opsmx-isd apply -f migration_v403_to_v4031.yaml`

    - Once the above command is executed new pod will be created is running so please check the pod logs to verify if the Schema is updated or not.

      Below is the sample log message:

      ```console
      2023-05-11 16:05:18.101  INFO 7 --- [ task-1] c.o.a.events.UserActivityEvent : User activity data migration started
      2023-05-11 16:05:18.582  INFO 7 --- [ task-1] c.o.a.events.UserActivityEvent : Migrated 39 user activity events successfully: 
      2023-05-11 16:05:18.583  INFO 7 --- [ task-1] c.o.a.events.UserActivityEvent : User activity data migration ended
      2023-05-11 16:05:18.606  INFO 7 --- [ task-1] c.o.a.events.PolicyAuditEvent  : Policy Audit data migration started
      2023-05-11 16:05:18.619  INFO 7 --- [ task-1] c.o.a.events.PolicyAuditEvent  : Should be a fresh install or Policy Audit events might have migrated already so not attempting migration now
      2023-05-11 16:05:18.633  INFO 7 --- [ task-1] c.o.a.events.PipelineConfigEvent : Pipeline Config data migration started
      2023-05-11 16:05:18.649  INFO 7 --- [ task-1] c.o.a.events.PipelineConfigEvent : Should be a fresh install or Pipeline Config events might have migrated already so not attempting migration now
      2023-05-11 16:05:18.653  INFO 7 --- [ task-1] c.o.auditservice.events.MigrationEvent : database migration Ended
      ```

     - Once the migration is sucessfull delete the migration yaml

        `kubectl -n opsmx-isd delete -f migration_v403_to_v4031.yaml`

12. `kubectl -n opsmx-isd replace --force -f ISD-Generate-yamls-job.yaml`
   [ Wait for isd-generate-yamls-* pod to complete ]

    - Once the pod is completed please check the pod logs to verify manifest files are updated in GIt or not.

         `kubectl -n opsmx-isd logs isd-generate-yamls-xxx -c git-clone` #Replacing the name of the pod name correctly, check if your gitops-repo is cloned correctly

13. Compare and merge branch: This job should have created a branch on the gitops-repo with the helmchart version number specified in upgrade-inputcm.yaml. Raise a PR and check what changes are being made. Once satisfied, merge the PR.

14. `kubectl -n opsmx-isd replace --force -f ISD-Apply-yamls-job.yaml`
   Wait for isd-yaml-update-* pod to complete

    - Once pod will completed so please check the pod logs to verify manifest files are updated in Git or not.

      `kubectl -n opsmx-isd logs isd-apply-yamls-xxx -c git-clone` #Replacing the name of the pod name correctly, check if your gitops-repo is cloned correctly

      `kubectl -n opsmx-isd logs isd-apply-yamls-xxx -c script` #Replacing the name of the pod name correctly, check the log of the script that pushes the yamls and applies them

15. isd-spinnaker-halyard-0 pod should restart automatically. If not, execute this:

      - `kubectl -n opsmx-isd  delete po isd-spinnaker-halyard-0`

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
1. `kubectl -n opsmx-isd  delete sts isd-spinnaker-halyard`
2. `kubectl -n opsmx-isd  delete deploy --all`
3. `kubectl -n opsmx-isd delete svc --all`
4. `kubectl -n opsmx-isd replace --force -f ISD-Apply-yamls-job.yaml`
5.  Wait for all the pods to come up

