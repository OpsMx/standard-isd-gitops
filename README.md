# gitops2-install
2nd pass of installation instructions

Installation Instructions
1. Create an empty-repo (called the "gitops-repo"), rename "main" branch as master and clone it locally
2. clone helm-install-update, Copy contents of standard-isd-gitops to the gitops-repo created above
3. Depending your version, select the values.yaml_3.nn file and copy to "values.yaml" .e.g:
      cp values.yaml_3.12 values.yaml
TODO: Clean-up all the sample values.yamls WITH COMMENTS, remove "sai", set the defaults correct

4. In the gitops-repo cloned to disk and edit initialinstall/inputcm.yaml. This should be updated with version of ISD, gitrepo and user details.
     TODO: create one for each version as a branch, so nothing else is needed to be updated except the repo details
5. Update Values.yaml as required, specifically, the ISD URL, SSO and gitops repo (need clear instructions here)

7. Push all changes in the gitops-repo to git (git add; git commit;git push)

7. Create the following secrets. The default values are provided

kubectl -n opsmx-isd create secret generic gittoken --from-literal=gittoken=<YOUR TOKEN>

kubectl -n opsmx-isd create secret generic ldapconfigpassword --from-literal ldapconfigpassword=opsmxadmin123

kubectl -n opsmx-isd create secret generic ldappassword --from-literal ldappassword=opsmxadmin123

kubectl -n opsmx-isd create secret generic miniopassword --from-literal miniopassword=spinnakeradmin

kubectl -n opsmx-isd create secret generic redispassword --from-literal redispassword=password

kubectl -n opsmx-isd create secret generic saporpassword --from-literal saporpassword=saporadmin

kubectl -n opsmx-isd create secret generic dbpassword --from-literal dbpassword=networks123

kubectl -n opsmx-isd create secret generic rabbitmqpassword --from-literal rabbitmqpassword=Networks123

kubectl -n opsmx-isd create secret generic keystorepassword --from-literal keystorepassword=changeit

8. Create a configmap for inputs and a service account as follows:

kubectl -n opsmx-isd apply -f initialinstall/inputcm.yaml  # TODO RENAME initialinstall to just install

kubectl -n opsmx-isd apply -f serviceaccount.yaml

9. Initiate the installation by executing this command:

kubectl -n opsmx-isd apply -f initialinstall/ISD-Install-Job.yaml




