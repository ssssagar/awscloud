terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "5.21.0"
		}
	}

	#backend "s3" {
	#	bucket = "121020128018024-account"
	#	region = "us-east-1"
	#	key = "terraform/server/AWS-Jenkins-DVM1/infra_tfstate/terraform.tfstate"
	#}
}

provider "aws" {
	region = var.aws_region
}
