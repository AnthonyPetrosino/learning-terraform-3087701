output "instance_ami" {
  value = aws_instance.app.ami
}
output "instance_arn" {
  value = aws_instance.app.arn
