
output "ec2_pubic_ip" {
  value = module.myapp-server.instance.public_ip
}