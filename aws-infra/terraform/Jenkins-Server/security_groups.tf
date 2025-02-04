resource "aws_security_group" "jenkins_server_sg" {
	name = "${var.server_name}_sg"
	description = "${var.server_name} Security Group"
	vpc_id = data.aws_subnet.public_subnet.vpc_id
	ingress {
		description 	= "SSH from Torstar VPN"
		from_port 		= 22
		to_port 		= 22
		protocol 		= "tcp"
		cidr_blocks 	= [ "0.0.0.0/0" ]
	}

	ingress {
		description 	= "jenkins server ui"
		from_port 		= 8080
		to_port 		= 8080 
		protocol 		= "tcp"
		cidr_blocks 	= [ "0.0.0.0/0" ]
	}

	egress {
		from_port 			= 0
		to_port 			= 0
		protocol 			= "-1"
		cidr_blocks 		= [ "0.0.0.0/0" ]
		ipv6_cidr_blocks 	= [ "::/0" ]
	}

	tags = {
		Name = "${var.server_name}_sg"
	}
}