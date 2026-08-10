resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/${var.project_name}-grafana"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-grafana-logs"
  }
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.project_name}-grafana"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-grafana"
      image     = "${data.terraform_remote_state.ecr.outputs.grafana_repository_url}:v1"
      essential = true

      portMappings = [
        {
          containerPort = 3000 
          protocol      = "tcp"
        }
      ]

      secrets = [
        {
          name      = "GF_SECURITY_ADMIN_PASSWORD"
          valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/air/grafana/admin-password"
        }
      ]

      environment = [
        {
          name  = "GF_SECURITY_ADMIN_USER"
          value = "admin"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-grafana-task"
  }
}

resource "aws_ecs_service" "grafana" {
  name            = "${var.project_name}-grafana-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.terraform_remote_state.network.outputs.private_subnet_ids
    security_groups  = [aws_security_group.grafana.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "${var.project_name}-grafana"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.grafana]
}