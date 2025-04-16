resource "aws_vpc" "my_vpc"{
    cidr_block = var.cidr
}

resource "aws_subnet" "subnet1"{
    vpc_id = aws_vpc.my_vpc.id
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
    cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "subnet2"{
    vpc_id = aws_vpc.my_vpc.id
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true
    cidr_block = "10.0.2.0/24"
}


resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "rt"{
    vpc_id = aws_vpc.my_vpc.id

    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}


resource "aws_route_table_association" "rta1"{
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta2"{
    subnet_id = aws_subnet.subnet2.id
    route_table_id = aws_route_table.rt.id
}


resource "aws_security_group" "webSG"{
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "webSG"
    }

    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
     ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "outbound rules"
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]

    }


}
resource "aws_instance" "webserver1" {
    ami = "ami-0e35ddab05955cf57"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.webSG.id]
    subnet_id = aws_subnet.subnet2.id
    user_data = base64encode(file("userdata1.sh"))

}

resource "aws_instance" "webserver2" {
    ami = "ami-0e35ddab05955cf57"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.webSG.id]
    subnet_id = aws_subnet.subnet2.id
    user_data = base64encode(file("userdata2.sh"))


}


resource "aws_alb" "alb" {
    name = "aws-lb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.webSG.id]
    subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

resource "aws_lb_target_group" "tg" {
  name     ="my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }

}

resource "aws_lb_target_group_attachment" "tga1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tga2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "live_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

output "aws_alb_dns" {
    description = "the value of loadbalancer dns"
    value = aws_alb.alb.dns_name
}