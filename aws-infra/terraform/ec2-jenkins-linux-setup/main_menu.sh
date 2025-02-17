#!/bin/zsh

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
ENDCOLOR="\e[0m"
TAB="\t"

echo "${CYAN}Fetching AWS Credentials${ENDCOLOR}"
fetch_aws_creds() {
    export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile default);
    export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile default);
    export AWS_SESSION_TOKEN=$(aws configure get aws_session_token --profile default);
}
fetch_aws_creds

echo "${CYAN}Infrastructure creation is started.${ENDCOLOR}"

show_menu() {
    echo "Menu:"
    echo "1) Terraform init (It will download required dependencies like providers, modules etc)"
    echo "2) Terraform plan (It will not create resources)"
    echo "3) Terraform apply auto approve (It will create resources)"
    echo "4) Terraform plan distroy (It will not distroy resources)"
    echo "5) Terraform distroy auto approve (It will distroy resources)"
    echo "6) Exit"
}

while true; do
    show_menu
    fetch_aws_creds
    echo -n "Enter your choice [1-6]: "
    read choice

    case $choice in
        1)

            echo "Terraform init (It will download required dependencies like providers, modules etc)"
            docker run -it --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace -v ~/Downloads/keys:/workspace/keys hashicorp/terraform:1.9 init
            ;;
        2)

            echo "Terraform plan (It will not create resources)"
            docker run -it --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace -v ~/Downloads/keys:/workspace/keys hashicorp/terraform:1.9 plan
            ;;
        3)
            echo "Terraform apply auto approve (It will create resources)"
            docker run -it --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace -v ~//Downloads/keys:/workspace/keys hashicorp/terraform:1.9 apply --auto-approve
            ;;
        4)
            echo "Terraform plan distroy (It will not distroy resources)"
            docker run -it --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace -v ~//Downloads/keys:/workspace/keys hashicorp/terraform:1.9 plan -destroy
            ;;
        5)
            echo "Terraform distroy auto approve (It will distroy resources)"
            docker run -it --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace -v ~//Downloads/keys:/workspace/keys hashicorp/terraform:1.9 destroy --auto-approve
            ;;
        6)
            echo "Exiting"
            break
            ;;
        *)
            echo "Invalid choice. Please select an option between 1 and 5."
            ;;
    esac

    echo
done
