provider "aws" {
  region = "us-east-1"
}



resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}



# resource "aws_internet_gateway" "myapp-igw" {
#   vpc_id = aws_vpc.myapp-vpc.id
#   tags = {
#     Name: "${var.env_prefix}-igw"
#   }
# }

/*resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-rtb"
  }
}*/

/*resource "aws_route_table_association" "a-rtb_subnet" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
  
}*/

#How to use default route table.check 

# resource "aws_default_route_table" "main-rtb" {
#   default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp-igw.id
#   }
#   tags = {
#     Name: "${var.env_prefix}-rtb"
#   }

  
# }

#values are defined in .tfvars file
# Set values in variables.tf in root
#values are passed to child module as arguments via variables.tf in child module
module "myapp-subnet" {
  source = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  
}

module "myapp-server" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.myapp-vpc.id
  my_ip = var.my_ip
  env_prefix = var.env_prefix
  image_name = var.image_name
  public_key_location = var.public_key_location
  instance_type = var.instance_type
  subnet_id = module.myapp-subnet.subnet.id
  avail_zone = var.avail_zone

}


