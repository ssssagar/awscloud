resource "aws_key_pair" "vpnkey" { 
	key_name = var.vpnkeyname
	public_key = file(var.PATH_TO_PUBLIC_KEY) 
}