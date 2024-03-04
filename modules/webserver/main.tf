resource "aws_default_security_group" "default-sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = [var.my_ip]
  }
  
  ingress  {
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name: "${var.env_prefix}-default-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
most_recent = true
owners = ["amazon"]
filter {
  name = "name"
  values = [var.image_name]
}
filter {
  name = "virtualization-type"
  values = ["hvm"]
}

  }



resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = file(var.public_key_location)

  
}

resource "aws_instance" "myapp-server" {
  ami= data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entry-script.sh")

  user_data_replace_on_change = true
#for terraform to enter the server , to run the commands , there must be a connection
# connection {
#   type = "ssh"
#   host = self.public_ip
#   user = "ec2-user"
#   private_key = file(var.private_key_location)
# }

#File provisioner is used to copy files or directories form local to newly created resource
#source - source file or folder
#destination - absolute path
# provisioner "file" {
#   source = "entry-script.sh"
#   destination = "/home/ec2-user/entry-script-on-ec2.sh"
  
# }


# remote-exec gets into the server to run the inline commands
# provisioner "remote-exec" {
#   script = "entry-script.sh"
  
# }
/*
Provisioners are not recommended
-Use user_data if available
- Breaks idempotency concept
-TF doesn't know what you execute
-Breaks current-desired state

Alternative to remote-exec
- Use configuration management tools (puppet, Ansible, CHEF)
- Once server provisioned, hand over to those tools

Alternative to local-exec
-Use "local" provider

Alternatives
- Execute scripts separate from Terraform
- From CI/CD tool




*/

#local-exec provisioner invokes a local executables after a resource is created
#locally, NOT on the created resource!
# provisioner "local-exec" {
#   command = "echo ${self.public_ip} > output.txt"
# }

tags = {
    Name: "${var.env_prefix}-server"
    foo = "bar"
  }
  

}