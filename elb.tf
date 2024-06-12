#elastic load balancer

# Create a new load balancer
resource "aws_lb_target_group" "target-group" {
  name        = "interface-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.dev_vpc.id

tags = {
    name = "deham14"
  }

health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 10
  }

}

# creating ALB

resource "aws_lb" "application-lb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public-1.id,aws_subnet.public-2.id]
  security_groups    = [aws_security_group.web_sg.id]
  ip_address_type    = "ipv4"

  tags = {
    name = "deham14"
  }
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.application-lb.arn
  port              = 80
  protocol          = "HTTP"


   default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

resource "aws_lb_target_group_attachment" "ec2_attach" {
  count            = length(aws_instance.instance)
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = aws_instance.instance[count.index].id
}