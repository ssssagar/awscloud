data "aws_subnet" "public_subnet" {
  filter {
    name   = "mapPublicIpOnLaunch"
    values = ["true"]
  }

  # Replace with your desired AZ
  filter {
    name   = "availability-zone"
    # values = ["us-east-1a"]
    values = [var.availability_zone]
  }
}
