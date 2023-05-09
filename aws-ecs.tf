# AWS provider configuration
provider "aws" {
  region = "us-west-2" # Replace with your desired region
}

resource "aws_vpc" "ecs_cluster_vpc" {
  cidr_block = "10.0.0.0/16" # Replace with your desired CIDR block
}

resource "aws_subnet" "ecs_cluster_subnet" {
  vpc_id = aws_vpc.ecs_cluster_vpc.id
  cidr_block = "10.0.1.0/24" # Replace with your desired CIDR block
}

resource "aws_internet_gateway" "ecs_cluster_igw" {
  vpc_id = aws_vpc.ecs_cluster_vpc.id
}

resource "aws_route_table" "ecs_cluster_rt" {
  vpc_id = aws_vpc.ecs_cluster_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_cluster_igw.id
  }
}
resource "aws_route_table_association" "ecs_cluster_rta" {
  subnet_id = aws_subnet.ecs_cluster_subnet.id
  route_table_id = aws_route_table.ecs_cluster_rt.id
}

resource "aws_security_group" "ecs_cluster_sg" {
  name_prefix = "ecs-cluster-sg-"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "my_project_cluster" {
  name = "my-project-cluster" # Replace with your desired cluster name
}

# Create the Task Definition
resource "aws_ecs_task_definition" "my_project_task" {
  family = "my-project-task" # Replace with your desired task family name
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name = "my-project-container"
      image = "<your-repository-url>/<your-image-name>:<your-image-tag>"
      portMappings = [
        {
          containerPort = 80
          hostPort = 80
          protocol = "tcp"
        }
      ]
      logConfiguration {
        logDriver = "awslogs"
        options = {
          "awslogs-region" = "us-west-2" # Replace with your desired region
          "awslogs-group" = "my-project-logs" # Replace with your desired log group name
          "awslogs-stream-prefix" = "my-project-container"
        }
      }
    }
  ])
  
  # Attach the Security Group to the Task Definition
  network_configuration {
    security_groups = [aws_security_group.ecs_cluster_sg.id]
    subnets = [aws_subnet.ecs_cluster_subnet.id]
  }
}

resource "aws_ecs_service" "my_project_service" {
  name = "my-project-service" # Replace with your desired service name
  cluster = aws_ecs_cluster.my_project_cluster.id
  task_definition = aws_ecs_task_definition.my_project_task.arn
  desired_count = 1
  launch_type = "FARGATE"

