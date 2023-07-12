# Update Instructions

Please follow these instructions if you are updating any values after the installation. The current installation could have been installed using helm or using the gitops installer. Please follow the steps as per your current scenario.

# Use this set if instructions if:

a) You have a 4.0.3.1 installed and required to update values
b) Already have a gitops-repo for ISD (AP and Spinnaker) Configuration

Execute these commands, replacing "gitops-repo" with your repo
- `git clone `**https://github.com/.../gitops-repo**
- `cd gitops-repo`
- Check that if a "values.yaml" file exists in this directory (root of the gitops-repo).
- Edit the existing "values.yaml", that was used for previous installation and do the changes according to your needs.

## Common Steps
1. Ensure that "default" account is configured to deploy to the ISD namespace (e.g. oes)
2. Push changes to git: `git add -A; git commit -m "Updated related changes";git push`
3. `kubectl -n opsmx-isd replace --force -f ISD-Generate-yamls-job.yaml`
   [ Wait for isd-generate-yamls-* pod to complete ]
4. Compare and merge branch: This job should have created a branch on the gitops-repo with the helmchart version number specified in upgrade-inputcm.yaml. Raise a PR and check what changes are being made. Once satisfied, merge the PR.
5. `kubectl -n opsmx-isd replace --force -f ISD-Apply-yamls-job.yaml`
   Wait for isd-yaml-update-* pod to complete, and all pods to stabilize
6. isd-spinnaker-halyard-0 pod should restart automatically. If not, execute this: `kubectl -n opsmx-isd  delete po isd-spinnaker-halyard-0`
7. Restart all pods:
   - `kubectl -n opsmx-isd scale deploy -l app=oes --replicas=0` Wait for a min or two
   - `kubectl -n opsmx-isd scale deploy -l app=oes --replicas=1` Wait for all pods to come to ready state
 
8. Go to ISD UI and check if it is up successfully.
9. Wait for about 5 min for autoconfiguration to take place.
10. If required: a) Connect Spinnaker again b) Configure pipeline-promotion again. To do this, in the ISD UI:
   - Click setup
   - Click Spinnaker tab at the top. Check if "External Accounts" and "Pipeline-promotion" columns show "yes". If any of them is "no":
   - Click "edit" on the 3 dots on the far right. Check the values already filled in, make changes if required and click "update".
   - Restart the halyard pod by clicking "Sync Accounts to Spinnaker" in the Cloud Accounts tab or simply delete the halyard pod




