provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "web_server" {
  count         = 2
  ami           = "ami-0f5ee92e2d63afc18"   # Example Amazon Linux AMI (change if needed)
  instance_type = "t2.micro"

  tags = {
    Name = "web-server-${count.index}"
  }
}

resource "aws_lb" "web_lb" {
  name               = "web-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [] # Add security group IDs here
  subnets            = [] # Add subnet IDs here

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "web_target_group" {
  name        = "web-target-group"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = "vpc-xxxxxxxx" # Replace with your VPC ID
  target_type = "instance"
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "web_target_attachment" {
  count            = length(aws_instance.web_server)
  target_group_arn = aws_lb_target_group.web_target_group.arn
  target_id        = aws_instance.web_server[count.index].id
  port             = 80
}
