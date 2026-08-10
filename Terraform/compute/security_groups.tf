resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Permite trafego HTTP de entrada para o ALB"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "HTTP da internet (app)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP da internet (grafana)"
    from_port   = 3000
    to_port     = 3000
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

    ingress {
    description     = "Trafego do ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Trafego do Prometheus (scrape de metricas)"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.prometheus.id]
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

resource "aws_security_group" "prometheus" {
  name        = "${var.project_name}-prometheus-sg"
  description = "Permite trafego interno para o Prometheus"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

ingress {
    description = "Trafego interno da VPC (Grafana vai acessar daqui)"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] 
  }

  egress {
    description = "Permite todo trafego de saida (raspar metricas, puxar imagem)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-prometheus-sg"
  }
}

resource "aws_security_group" "grafana" {
  name        = "${var.project_name}-grafana-sg"
  description = "Permite trafego do ALB para o Grafana"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description     = "Trafego do ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Permite todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-grafana-sg"
  }
}

