resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Permite trafego HTTP de entrada para o ALB"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "HTTP da internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Permite todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Security Group do ECS - só aceita trafego vindo do ALB (nunca direto da internet)
resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-ecs-sg"
  description = "Permite trafego apenas do ALB"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description     = "Trafego do ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # aqui é a mágica: só aceita do SG do ALB
  }

  egress {
    description = "Permite todo trafego de saida (ex: puxar imagem do ECR, chamar APIs externas)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ecs-sg"
  }
}