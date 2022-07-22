TODO: TEST 
TODO: Add trouble shooting steps
TODO: Move changes from standard-gitops-repo 3.12 to gitops-repo: What are they? Any critical changes?

# Upgrade Instructions

Please follow these instructions if you are upgrading from 3.11 (to 3.12). The previous installtion (3.11) could have been installed using helm (Scenario A) or using the gitops installer (Scenario B). Please follow the steps as per your current scenario.

## Scenario A
Use this set if instructions if:
- You have a 3.11 installed using the helm installer (installated prio to Feb 2022) and
- Already have a "gitops-repo" for Spinnaker Configuration

Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**http://github.com/.../gitops-repo**
- `git clone https://github.com/OpsMx/standard-isd-gitops.git -b 3.12`
- `cp -r standard-isd-gitops.git/upgrade gitops-repo`  
- `cd gitops-repo`
- `cd upgrade`

## Scenario B
Use this set if instructions if:
a) You have a 3.11 installed using gitops installer
b) Already have a gitops-repo for ISD (AP and Spinnaker) Configuration

Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**http://github.com/.../gitops-repo**
- `cd <your gitops-repo>`
- `cd upgrade`

## Common Steps
Upgrade sequence: (3.10 to 3.11)
A) Copy url, username and gitmeail from input/inputcm.yaml to upgrade/inputcm.yaml
B) Values.yaml from 3.11: add gitea.enabled=false, ensure atuoinstall-sample-app - set to false if you don't want to override your pipelines
c) Upgrade DB - Run pipeline?
   Cd upgrade
d) kubectl -n opsmx-isd apply -f inputcm.yaml
D) kubectl -n opsmx-isd replace --force -f ISD-Generate-yamls-job.yaml
   Wait for isd-generate-yamls-* pod to complete
E) Compare and merge branch
F) kubectl -n opsmx-isd apply -f ISD-Apply-yamls-job.yaml
   Wait for isd-yaml-update-* pod to complete, and all pods to stabilize
g) isd-spinnaker-halyard-0 pod should restart automatically. If not, execute this: kubectl -n opsmx-isd  delete po isd-spinnaker-halyard-0
H) Go to ISD UI and check that version number has changed in the bottom-left corner

If things go wrong:
[Make changes to ineputcm, values.yaml as required]
a) kubectl -n opsmx-isd  delete sts isd-spinnaker-halyard
b) kubectl -n opsmx-isd  delete deploy --all
c) kubectl -n opsmx-isd delete svc --all
c) DELETE ALL DB INFO: Note that pipelines data may be lost: kubectl -n opsmx-isd delete pvc --all
c) kubectl -n opsmx-isd replace --force -f ISD-Apply-yamls-job.yaml
e) Wait for all the pods to come up: How do we KNOW if it has ended?
