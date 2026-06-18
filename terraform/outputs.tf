output "api_gateway_public_ip" {
  description = "The public IP address of the API Gateway (VM 1)"
  value       = aws_instance.vm_1_engine.public_ip
}
