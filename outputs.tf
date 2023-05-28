output "ssh_command" {
  value = "ssh -i ${pathexpand("${var.private_ssh_key_dir}/${var.app_name}-${var.deployment_name}.pem")} core@${aws_instance.minecraft.public_ip}"
}