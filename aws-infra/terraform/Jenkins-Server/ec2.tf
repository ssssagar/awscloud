# Launch EC2 server
resource "aws_instance" "server" {
	ami = var.server_ami_map[var.os_type][var.aws_region]
	instance_type = var.server_instance_type
	iam_instance_profile = aws_iam_instance_profile.server_instance_profile.name

	tags = {
		Name = var.server_name
		Env = var.env_tag 
	}

	key_name = aws_key_pair.vpnkey.key_name
	security_groups = [ "${aws_security_group.jenkins_server_sg.id}" ]
	subnet_id = data.aws_subnet.public_subnet.id
	user_data = data.cloudinit_config.cloudinit-ebs-mount.rendered
	root_block_device {
		delete_on_termination = false
		volume_size = var.root_volume_size
		volume_type = var.root_volume_type
		encrypted = true
	}

  	lifecycle {
	    ignore_changes = [
	      security_groups,
	    ]
  	}

  	provisioner "local-exec" {
	    command = <<EOT
			cat <<EOF > ./login.sh
			#!/bin/bash
			ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/Downloads/keys/jenkins-key ubuntu@${self.public_ip}
			EOF
			chmod +x ./login.sh
			EOT
	}
}

resource "aws_ebs_volume" "server_volume" {
	availability_zone = aws_instance.server.availability_zone
	size = var.ebs_volume_size
	type = var.ebs_volume_type

	tags = {
		Name = "$(var.server_name) volume data"
	}
}

resource "aws_volume_attachment" "ebs-volume-attachment" {
	device_name 	= var.server_ebs_instance_device_name
	volume_id 		= aws_ebs_volume.server_volume.id
	instance_id 	= aws_instance.server.id
	skip_destroy 	= true

  	lifecycle {
	    ignore_changes = [
	      instance_id,
	      volume_id
	    ]
  	}
}