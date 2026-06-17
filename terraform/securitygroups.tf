# Security Group for the API Gateway (VM 1)
resource "aws_security_group" "api_gateway" {
  name        = "api-gateway-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP Traffic via NGINX"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS Traffic via NGINX"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Workers (VM 2 & 3)
resource "aws_security_group" "workers" {
  name        = "worker-sg"
  vpc_id      = aws_vpc.main.id

  # No Ingress rules required! The workers initiate the outbound WebSocket 
  # connection to the API Gateway. They don't accept incoming requests.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
