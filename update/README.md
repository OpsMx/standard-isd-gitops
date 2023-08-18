# Update Instructions

Please follow these instructions if you are updating any values in values.yaml after the installation.

# Please use below set of instructions:

a) You have a 4.0.4 installed and required to update values

b) Already have a gitops-repo for ISD (AP and Spinnaker) Configuration

1. Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**https://github.com/.../gitops-repo**
- `cd gitops-repo`
2. Check that if a "values.yaml" file exists in this directory (root of the gitops-repo).
3. Edit the existing "values.yaml", that was used for previous installation and do the changes according to your needs.
4. Push changes to git: `git add -A; git commit -m "Updated related changes";git push`
5. `kubectl -n opsmx-isd replace --force -f ISD-Generate-yamls-job.yaml`
   [ Wait for isd-generate-yamls-* pod to complete ]
6. Compare and merge branch: This job should have created a branch on the gitops-repo with the helmchart version number specified in upgrade-inputcm.yaml. Raise a PR and check what changes are being made. Once satisfied, merge the PR.
7. `kubectl -n opsmx-isd replace --force -f ISD-Apply-yamls-job.yaml` # Replace the namespace accordingly
   Wait for isd-yaml-update-* pod to complete, and all pods to stabilize
8. If any pods did not restart after the changes please restart the pods. Below is the command to restart all the pods
   - `kubectl -n opsmx-isd scale deploy -l app=oes --replicas=0` Wait for a min or two
   - `kubectl -n opsmx-isd scale deploy -l app=oes --replicas=1` Wait for all pods to come to ready state
 
10. Go to ISD UI and check if it is up successfully.
11. If required: a) Connect Spinnaker again b) Configure pipeline-promotion again. To do this, in the ISD UI:
   - Click setup
   - Click Spinnaker tab at the top. Check if "External Accounts" and "Pipeline-promotion" columns show "yes". If any of them is "no":
   - Click "edit" on the 3 dots on the far right. Check the values already filled in, make changes if required and click "update".
   - Restart the halyard pod by clicking "Sync Accounts to Spinnaker" in the Cloud Accounts tab or simply delete the halyard pod




