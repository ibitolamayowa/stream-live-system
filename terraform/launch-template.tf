resource "aws_eip" "aws_eip" {
    vpc = true
}

resource "aws_network_interface" "aws_network_interface" {
  subnet_id = aws_subnet.aws_subnet_a.id
}

resource "aws_eip_association" "aws_eip_association" {
    allocation_id = aws_eip.aws_eip.id
    network_interface_id = aws_network_interface.aws_network_interface.id
}


resource "aws_launch_template" "aws_launch_template" {
  depends_on = [aws_vpc.aws_vpc, aws_security_group.aws_security_group]
  image_id      = "ami-0f00bebfda848baa2"
  instance_type = "t2.small"
  key_name = "terraform"
  vpc_security_group_ids = [aws_security_group.aws_security_group.id]
  user_data = filebase64("./launch-config.sh")
  network_interfaces {
    network_interface_id = aws_network_interface.aws_network_interface.id
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "aws_autoscaling_group" {
  depends_on = [aws_launch_template.aws_launch_template]
//  availability_zones = ["us-west-2a","us-west-2b"]
  desired_capacity  = 1
  max_size          = 3
  min_size          = 1
  vpc_zone_identifier = [aws_subnet.aws_subnet_a.id, aws_subnet.aws_subnet_b.id]
  launch_template {
    id      = aws_launch_template.aws_launch_template.id
    version = "$Latest"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This will trigger when cpu utilization goes above 80%"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
  statistic           = "Average"
  threshold           = "30"
  alarm_description   = "This will trigger when cpu utilization goes below 30%"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
}

resource "aws_autoscaling_policy" "scale_up" {
  name                       = "scale-up"
  adjustment_type            = "ChangeInCapacity"
  autoscaling_group_name     = aws_autoscaling_group.aws_autoscaling_group.name
  scaling_adjustment         = 1
  cooldown                   = 300
}

resource "aws_autoscaling_policy" "scale_down" {
  name                       = "scale-down"
  adjustment_type            = "ChangeInCapacity"
  autoscaling_group_name     = aws_autoscaling_group.aws_autoscaling_group.name
  scaling_adjustment         = -1
  cooldown                   = 300
}