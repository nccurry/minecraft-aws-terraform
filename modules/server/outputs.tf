output "public_ip_address" {
  value = aws_eip.eip.public_ip
}

output "private_key" {
  value = aws_secretsmanager_secret_version.private_key.secret_string
  sensitive = true
}