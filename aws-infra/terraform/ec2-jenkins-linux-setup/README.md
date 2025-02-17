# jenkins infra setup

We will be using terraform to create and configure Jenkins server. For server configuration we will be using terraform cloud-init provisioners, it will use SSH (Port 22) to connect to server and execute commands on remote server created by AWS, please update appropriate path of private keypair in connection block of main.tf and map the same in docker container.

Steps:
1. Configuring AWS Access:
```
AWS_ACCESS_KEY_ID=$(aws —profile <profile_name> configure get aws_access_key_id);
AWS_SECRET_ACCESS_KEY=$(aws -profile <profile_name> configure get aws_secret_access_key):
AWS_SESSION_TOKEN=$(aws -profile <profile_name> configure get aws_session_token);
```


Please use https://github.com/SMG-Digital/Ops-Scripts/blob/master/python/sts.py to switch Another AWS Account <AWS Account Number>.

2. Initialize Terraform
 docker run -it --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -w /workspace -v $PWD:/workspace -v /Users/sagarbholvankar/Downloads/keys:/workspace/keys hashicorp/terraform:1.4.6 init

3. Executing Terraform Plan
ltfusername=$(whoami) && docker run -it —rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace -v /Users/"$(whoami)"/Downloads/keys:/workspace/keys hashicorp/terraform:1.4.6 plan

4. Executing Terraform Apply
docker run -it —rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace -v /Users/"$(whoami)"/Downloads/keys:/workspace/keys hashicorp/terraform:1.4.6 apply

5. Executing Terraform destroy preview
docker run -it —rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace -v /Users/"$(whoami)"/Downloads/keys:/workspace/keys hashicorp/terraform:1.4.6 plan -destroy

6. Executing Terraform destroy (Double confirm the step 5 and get it reviewed with DevOps team)
docker run -it —rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace -v /Users/"$(whoami)"/Downloads/keys:/workspace/keys hashicorp/terraform:1.4.6 destroy