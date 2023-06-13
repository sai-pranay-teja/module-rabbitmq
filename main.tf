
resource "aws_route53_record" "component-records" {
    zone_id = data.aws_route53_zone.mine.zone_id
    name    = "rabbitmq-${var.env}.practise-devops.online"
    type    = "A"
    ttl     = 30
    records = [aws_spot_instance_request.rabbitmq.private_ip]
}


resource "aws_spot_instance_request" "rabbitmq" {
  ami           = data.aws_ami.centos-ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [ aws_security_group.rabbitmq-traffic.id ]
  subnet_id = var.subnet_ids[0]
  wait_for_fulfillment="true"
  spot_type="persistent"
  iam_instance_profile = aws_iam_instance_profile.Full-access-profile.name

  instance_interruption_behavior="stop"
  user_data = base64encode(templatefile("${path.module}/userdata.sh" , {
    component=var.component


  }))

  tags = {
        Name = "${var.env}-rabbitmq-server"
    }

  timeouts {
    create = "60m"
    delete = "2h"
  }
}

resource "aws_ec2_tag" "component-tags" {
    resource_id = aws_spot_instance_request.rabbitmq.spot_instance_id
    key         = "Name"
    value       = "${var.env}-Rabbitmq"
}

resource "aws_security_group" "rabbitmq-traffic" {
  name        = "Rabbitmq traffic"
  description = "Rabbitmq traffic"
  vpc_id=var.vpc_id


  ingress {
    description      = "RabbitMQ Traffic"
    from_port        = 5672
    to_port          = 5672
    protocol         = "tcp"
    cidr_blocks      = var.allow_subnets
  }

  ingress {
    description      = "SSH Traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.bastion_host
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env}-Rabbitmq traffic"
  }
}





