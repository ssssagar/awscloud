# Define a cloud-init configuration data source named "cloudinit-example" 
data "cloudinit_config" "cloudinit-ebs-mount" {
	# Specify options for cloud-init 
	gzip = false
	base64_encode = false
	# Define the first part of the cloud-init configuration 
	part {
		filename = "init.cfg"
		content_type = "text/cloud-config"
		# Use a template file to generate content, passing the AWS region as a variable 
		content = templatefile("scripts/init.cfg", {
			REGION = var.aws_region
		})
	}

		# Define the second part of the cloud-init configuration 
	part {
			content_type = "text/x-shellscript"
		# Use a template file to generate content, passing the instance device name as a vartable 
		content = templatefile("scripts/ubuntu_configuration.sh", { 
			DEVICE = var.server_ebs_instance_device_name 
			JENKINS_VERSION = var.jenkins_version
			TERRAFORM_BIN_VERSION = var.terraform_version 
		})
	}
}