output "app_eip" {
  value = aws_eip.app_eip.*.public_ip
}

output "app_instance" {
  value = aws_instance.cloudcasts_web.id
}