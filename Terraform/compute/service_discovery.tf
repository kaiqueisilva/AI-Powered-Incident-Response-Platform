# Namespace privado - o "domínio" interno da nossa VPC
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.project_name}.local"
  description = "Namespace de service discovery para o projeto"
  vpc         = data.terraform_remote_state.network.outputs.vpc_id
}

# Registro de serviço - associa o nome DNS à nossa app
resource "aws_service_discovery_service" "app" {
  name = "app"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

}