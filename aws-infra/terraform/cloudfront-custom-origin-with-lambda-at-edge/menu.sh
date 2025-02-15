#!/bin/zsh

AWS_ACCESS_KEY_ID=$(aws --profile <profile_name> configure get aws_access_key_id);
AWS_SECRET_ACCESS_KEY=$(aws --profile <profile_name> configure get aws_secret_access_key);
AWS_SESSION_TOKEN=$(aws --profile <profile_name> configure get aws_session_token);

docker run -it --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace hashicorp/terraform:1.9 $@
