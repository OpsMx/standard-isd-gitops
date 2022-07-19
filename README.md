# Standard-isd-gitops

Installation Instructions
1. Create an empty-repo (called the "gitops-repo"), rename "main" branch as master and clone it locally
2. Clone https://github.com/OpsMx/standard-isd-gitops, selecting the appropriate branch. E.g:
   git clone https://github.com/OpsMx/  -b 3.12
3. Copy contents of the standard-isd-repo to the gitops-repo created above using:
   cp -r standard-isd-gitops/* gitops-repo
4. In the gitops-repo cloned to disk and edit initialinstall/inputcm.yaml. This should be updated with version of ISD, gitrepo and user details.
5. Update Values.yaml as required, specifically, the ISD URL, SSO and gitops repo (need clear instructions here)
TODO: Clean-up all the sample values.yamls WITH COMMENTS, remove "sai", set the defaults correct

6. Push all changes in the gitops-repo to git (git add; git commit;git push)

7. Create the following secrets. The default values are provided, except for gittoken. If you are using External SSO, DBs, etc. you might want to change them. Else, best to leave them at the defaults

kubectl -n opsmx-isd create secret generic gittoken --from-literal=gittoken=PUT_YOUR_GITTOKEN_HERE

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

kubectl -n opsmx-isd apply -f initialinstall/serviceaccount.yaml

9. Initiate the installation by executing this command:

kubectl -n opsmx-isd apply -f initialinstall/ISD-Install-Job.yaml

10. Wait for all pods to stabilize (about 10-20 min, depending on your cluster load). Check status using:

kubectl -n opsmx-isd get po -w

11. Access ISD using the URL specified in the values.yaml in step N




