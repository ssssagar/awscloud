variable "aws_region" {
	default = "us-east-1"
}

variable "server_name" { 
	type = string
	default = "jenkins-dev-master"
}

variable "os_type" {
  description = "Operating system to use for the EC2 instance"
  type        = string
  default     = "amazon-linux"  # Default OS to select: amazon-linux or ubuntu
}

variable "server_ami_map" {
  description = "Map of AMIs by region and OS type"
  type        = map(map(string))
  default     = {
    "ubuntu" = {
      "us-east-1" = "ami-0866a3c8686eaeeba"
      "us-west-2" = "ami-0c77c0e5d837d840e"
    }
    "amazon-linux" = {
      "us-east-1" = "ami-06b21ccaeff8cd686"
      "us-west-2" = "ami-00eb20669e0990cb4"
    }
  }
}



variable "server_instance_type" { 
	type = string 
	default = "t3.micro"
}

variable "subnet_id" { 
	type = string
	default = "subnet-0f6b8f4137592ae13"
}
variable "vpc_id" {
	type = string
	default = "vpc-0b0906aef46c05f00"
}

variable "env_tag" { 
	type = string 
	default = "Dev"
}

variable "vpnkeyname" {
	type = string 
	default = "jenkins-key"
}

variable "PATH_TO_PUBLIC_KEY" {
	type = string
	default = "keys/jenkins-key.pub"
}

variable "ebs_volume_type" {
	type = string 
	default = "gp3"
}

variable "ebs_volume_size" {
	type = number 
	default = 30
}

variable "server_ebs_instance_device_name" {
	type = string 
	default = "/dev/xvdh"
}

variable "root_volume_size" { 
	type = number
	default = 30
}
variable "root_volume_type" { 
	type = string
	default = "gp3" 
}

variable "jenkins_version" { 
	type = string
	default = "2.426.3"
}

variable "terraform_version" { 
	type = string
	default = "1.9.8-1"
}

variable "availability_zone" { 
	type = string
	default = "us-east-1a"
}
