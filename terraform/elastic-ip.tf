/* resource "aws_eip" "aws_eip" {
  vpc = true
}
resource "aws_autoscaling_attachment" "asg_eip" {
  autoscaling_group_name = aws_autoscaling_group.aws_autoscaling_group.name
  elastic_ip             = aws_eip.aws_eip.id
} */