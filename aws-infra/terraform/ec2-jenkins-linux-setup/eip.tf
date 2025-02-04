# resource "aws_eip" "server_eip" { 
# 	domain = "vpc"
# 	tags = {
# 		Name = "$(var.server_name)_server_elp"
# 	}
# }
# 
# resource "aws_eip_association" "eip_assoc_server" { 
# 	instance_id = aws_instance.server.id
# 	allocation_id = aws_eip-server_eip.id
# }