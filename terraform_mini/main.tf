provider "aws"{
    region = "ap-south-1"
}

resource "aws_key_pair" "app_key"{
    key_name = "app_key"
    public_key = file(".ssh/id_rsa.pub")

}


# variable "cidr"{
#     type = string
#     default = "10.0.0.0/16"
# }
# resource "aws_vpc" "my_vpc"{
#     cidr_block = var.cidr
# }

# resource "aws_subnet" "subnet1"{
#     vpc_id = aws_vpc.my_vpc.id
#     cidr_block = "10.0.1.0/24"
#     map_public_ip_on_launch = true
#     availability_zone = "ap-south-1a"
# }

# resource "aws_internet_gateway" "igw"{
#     vpc_id = aws_vpc.my_vpc.id
# }
# resource "aws_route_table" "rt1"{
#     vpc_id = aws_vpc.my_vpc

#     route {
#         gateway_id = aws_internet_gateway.igw.id
#         cidr_block = "0.0.0.0/0"
#     }

# }

# resource "aws_route_table_association" "rta1"{
#     subnet_id = aws_subnet.subnet1.id
#     route_table_id = aws_route_table.rt1.id
# }

resource "aws_security_group" "webSG" {
    #vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "WebSG"
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

}
# variable "ami_id"{
#     description = "the value to use ami"
# }
resource "aws_instance" "webserver1"{
    ami = "ami-0e35ddab05955cf57"
    instance_type = "t2.micro"
    #subnet_id = aws_subnet.subnet1
    vpc_security_group_ids = [aws_security_group.webSG.id]
    key_name = aws_key_pair.app_key.key_name
    connection {
            type     = "ssh"
            user     = "ubuntu"
            private_key = file(".ssh/id_rsa")
            host = self.public_ip
            }

    provisioner "file" {
        source      = "app.py"
        destination = "/home/ubuntu/app.py"
        
    }

    # provisioner "remote-exec" {
    #     inline = [
    #         "sudo apt-get update",
    #         "sudo apt-get install -y python3-pip",
    #         "cd /home/ubuntu",
    #         "sudo pip3 install flask",
    #         "sudo python3 app.py &",
    #         ]
    # }

    #flask can be installed on environment only so we need to create python environment

   provisioner "remote-exec" {
        inline = [
             "sudo apt-get update -y",
              "sudo apt-get install -y python3-pip python3-venv",
              "sudo su -",
              "cd /home/ubuntu",
              "python3 -m venv venv",
              "source venv/bin/activate && pip install flask",
              "nohup venv/bin/python /home/ubuntu/app.py > app.log 2>&1 &"
            ]
    }
 
}
output "public_ip"{
    description = "the public ip of the instance is:"
    value = aws_instance.webserver1.public_ip
}