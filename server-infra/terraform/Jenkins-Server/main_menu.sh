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

echo "${CYAN}Infrastructure creation is initialted.${ENDCOLOR}"

show_menu() {
    echo "Menu:"
    echo "1) Terraform plan (It will not create resources)"
    echo "2) Terraform apply auto approve (It will create resources)"
    echo "3) Terraform plan distroy (It will not distroy resources)"
    echo "4) Terraform distroy auto approve (It will distroy resources)"
    echo "5) Exit"
}

while true; do
    show_menu
    fetch_aws_creds
    echo -n "Enter your choice [1-5]: "
    read choice

    case $choice in
        1)

            echo "Terraform plan (It will not create resources)"
            docker run -it --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace -v ~/Downloads/keys:/workspace/keys hashicorp/terraform:1.4.6 plan
            ;;
        2)
            echo "Terraform apply auto approve (It will create resources)"
            docker run -it --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace -v ~//Downloads/keys:/workspace/keys hashicorp/terraform:1.4.6 apply --auto-approve
            ;;
        3)
            echo "Terraform plan distroy (It will not distroy resources)"
            docker run -it --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace -v ~//Downloads/keys:/workspace/keys hashicorp/terraform:1.4.6 plan -destroy
            ;;
        4)
            echo "Terraform distroy auto approve (It will distroy resources)"
            docker run -it --rm -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN -w /workspace -v $PWD:/workspace -v ~//Downloads/keys:/workspace/keys hashicorp/terraform:1.4.6 destroy --auto-approve
            ;;
        5)
            echo "Exiting"
            break
            ;;
        *)
            echo "Invalid choice. Please select an option between 1 and 5."
            ;;
    esac

    echo
done
