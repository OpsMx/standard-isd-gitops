TODO: 
- Rename inputcm.yaml in UPGRADE to upgrade-input.cm, file name AND CM name need to be changed
- Change DB-upgrade pipeline to a JOB
- Document on ISD backup 
- Add trouble shooting steps
- Move changes from standard-gitops-repo 3.12 to gitops-repo: What are they? Any critical changes?

# Upgrade Instructions

Please follow these instructions if you are upgrading from 3.11 (to 3.12). The current installtion (3.11) could have been installed using helm (Scenario A) or using the gitops installer (Scenario B). Please follow the steps as per your current scenario.

**WARNING**: Please backup all the databases, in particualr the Posgres DB, BEFORE begining the upgrade. Backup procedures may differ depending your usage of external DBs and Spinnaker configuration. Kindly refer to **THIS** document for backup procedures. 

## Scenario A
Use these instructions if:
- You have a 3.11 installed using the helm installer (installated prio to Feb 2022) and
- Already have a "gitops-repo" for Spinnaker Configuration
- Have values.yaml that was used for helm installation

Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**https://github.com/.../gitops-repo**
- `git clone https://github.com/OpsMx/standard-isd-gitops.git -b 3.12`
- `cp -r standard-isd-gitops.git/upgrade gitops-repo`  
- `cd gitops-repo`
- Copy the existing "values.yaml", that was used for installation as "values.yaml" (file name is important) into this directory (root of the gitops-repo)

## Scenario B
Use this set if instructions if:
a) You have a 3.11 installed using gitops installer
b) Already have a gitops-repo for ISD (AP and Spinnaker) Configuration

Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**https://github.com/.../gitops-repo**
- `cd <your gitops-repo>`
- Check that a "values.yaml" file exists in this directory (root of the gitops-repo)

## Common Steps
Upgrade sequence: (3.11 to 3.12)
1. Update Values.yaml: Edit as follows:
  - In the "global:" section, add the following
  'gitea: 
    enabled: false'
2. If you have modified "sampleapp" or "opsmx-gitops" applications, please backup them up using "syncToGit" pipeline opsmx-gitops application.
3. `cd upgrade`
4. Update upgradecm.yaml : url, username and gitemail MUST be updated. TIP: if you have install/inputcm.yaml from previous installation, simply copy-paste these lines here
5. Push changes to git: `git add -A; git commit -m"Upgrade related changes";git push`
6. Upgrade DB - Run pipeline?-- TO BE CHANGED TO A JOB
7. `kubectl -n opsmx-isd apply -f inputcm.yaml`
8. `kubectl -n opsmx-isd replace --force -f ISD-Generate-yamls-job.yaml`
   [ Wait for isd-generate-yamls-* pod to complete ]
8. Compare and merge branch
9. `kubectl -n opsmx-isd replace --force -f ISD-Apply-yamls-job.yaml`
   Wait for isd-yaml-update-* pod to complete, and all pods to stabilize
10 isd-spinnaker-halyard-0 pod should restart automatically. If not, execute this: `kubectl -n opsmx-isd  delete po isd-spinnaker-halyard-0`
11. Go to ISD UI and check that version number has changed in the bottom-left corner

## If things go wrong during upgrade
*As we have a gitops installer, recovering from a completed messed install is very easy. In summary, we simply delete all objects are re-apply.*

[Make changes to uppgrade-inputcm and/or values.yaml as required. **Ensure that the changes are pushed to git**]
1. `kubectl -n opsmx-isd  delete sts isd-spinnaker-halyard`
2. `kubectl -n opsmx-isd  delete deploy --all`
3. `kubectl -n opsmx-isd delete svc --all`
4. `kubectl -n opsmx-isd replace --force -f ISD-Apply-yamls-job.yaml`
5.  Wait for all the pods to come up: How do we KNOW if it has ended?

## Recovering from a failed "Upgrade DB" job
1. Restore PostgresDB from backup
**TBD**
