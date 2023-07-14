# Restore Instructions

Please follow these instructions if you are restoring any settings that has been missed or deleted during/after the installation.

# Please use this set of instructions:

a) You have a 4.0.3.1 installed and required to restore any settings.
b) Already have a gitops-repo configured for ISD (AP and Spinnaker) Configuration.

# Use Case 1: If a namespace is deleted in a cluster
These instructions can be followed when the ISD installed namespace is deleted by any chance and we need to restore our instance.

1. ISD stores all the configuration in the git repo, we can check for the "values.yaml" file that exists in the directory (root of the gitops-repo) that is already configured with the required parameters.
2. Use the same "values.yaml" and execute the below commands to install it again.
3. Execute `kubectl -n opsmx-isd replace --force -f ISD-Generate-yamls-job.yaml`
   [ Wait for isd-generate-yamls-* pod to complete ]
4. Compare and merge branch: This job should have created a branch on the gitops-repo with the helmchart version number specified in upgrade-inputcm.yaml. Raise a PR and check what changes are being made. Once satisfied, merge the PR.
5. `kubectl -n opsmx-isd replace --force -f ISD-Apply-yamls-job.yaml`
   Wait for isd-yaml-update-* pod to complete, and all pods to stabilize.

# Use Case 2: If any of the resources is deleted in the namespace
These instructions can be followed when any of the ISD resources like deployments,secrets,configmaps etc.. is deleted by any chance and we need to restore them.

1. ISD stores all the configuration in the git repo, in which we can find these resources in the location given below as an example.
-  `**https://github.com/.../gitops-repo/isd/oes/templates/deployments** # Replace "gitops-repo" with your repo-name
2. Fetch the missing resource files from that location and apply the same to our namespace.For example
-  `kubectl -n opsmx-oss apply -f oes-gate.yaml` # Replace the namespace and resource file accordingly








