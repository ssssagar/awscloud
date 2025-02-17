output "Server_URL" {
	value = "http://${aws_instance.server.public_ip}:8080"
}

output "Public_Server_Ip" {
	value = "${aws_instance.server.public_ip}"
}