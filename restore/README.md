# Restore Instructions

Please follow these instructions if any resources are being restored that has been deleted after the installation.

## Pre-requisites:

a) You have 4.0.4 installed and required to restore any settings.
b) Already have a gitops-repo configured for ISD (AP and Spinnaker) Configuration.

## Restore will be done in two cases
1. Namespace deleted from the cluster: When the ISD installed namespace is deleted by chance and we need to restore our instance.
2. Resource deleted from the Namespace: When any of the ISD resources like deployments,secrets,configmaps etc.. is deleted by chance and we need to restore them.

## 1) If a namespace is deleted in a cluster

1. Use the "values.yaml" stored in git and execute the below commands to install it again.
2. Execute the below commands to create namespace and install ISD:
- `kubectl create ns opsmx-isd` # Replace namespace "opsmx-isd" as required
- `kubectl -n opsmx-isd apply -f install/inputcm.yaml` # Replace namespace "opsmx-isd" as required
- `kubectl -n opsmx-isd apply -f install/serviceaccount.yaml` # Replace namespace "opsmx-isd" as required
- `kubectl -n opsmx-isd create secret generic gittoken --from-literal=gittoken=PUT_YOUR_GITTOKEN_HERE` # Replace namespace "opsmx-isd" as required
- `kubectl -n opsmx-isd apply -f install/ISD-Install-Job.yaml` # Replace namespace "opsmx-isd" as required
   Wait for isd-yaml-update-* pod to complete, and all the pods to stabilize.

## 2) If any of the resources is deleted in the namespace

1. We can find these resources in the git repo location given below as an example.
-  `**https://github.com/.../gitops-repo/isd/oes/templates/deployments** # Replace "gitops-repo" with your repo-name
2. Fetch the missing resource files from that location and apply the same to our namespace.For example
-  `kubectl -n opsmx-isd apply -f oes-gate-deployment.yaml` # Replace the namespace and resource file accordingly








