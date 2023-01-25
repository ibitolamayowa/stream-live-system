resource "aws_alb" "aws_alb" {
  name            = "aws-alb"
  internal        = false
  security_groups = [aws_security_group.aws_security_group.id]
  subnets         = [aws_subnet.aws_subnet_a.id, aws_subnet.aws_subnet_b.id]
}

resource "aws_alb_target_group" "root" {
  name     = "root"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.aws_vpc.id
  health_check {
    path = "/health"
    protocol = "HTTP"
    port = "traffic-port"
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 2
    interval = 60
  }
}

resource "aws_alb_target_group" "chat" {
  name     = "chat"
  port     = 4444
  protocol = "HTTP"
  vpc_id   = aws_vpc.aws_vpc.id
}

resource "aws_alb_target_group" "api" {
  name     = "api"
  port     = 3333
  protocol = "HTTP"
  vpc_id   = aws_vpc.aws_vpc.id
}

resource "aws_alb_target_group" "streams" {
  name     = "streams"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.aws_vpc.id
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.aws_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.root.arn
    type             = "forward"
  }
}

resource "aws_autoscaling_attachment" "root" {
  autoscaling_group_name = aws_autoscaling_group.aws_autoscaling_group.name
  lb_target_group_arn = aws_alb_target_group.root.arn
}