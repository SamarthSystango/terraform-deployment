resource "aws_ecs_cluster" "default" {
  name = "default"
}

resource "aws_ecs_task_definition" "default" {
  name = "default"
  container_definitions = [
    {
      name = "app"
      image = "nginx:latest"
      ports = [
        {
          container_port = 80
        }
      ]
    }
  ]
}

resource "aws_ecs_service" "default" {
  name = "default"
  cluster = aws_ecs_cluster.default.arn
  task_definition = aws_ecs_task_definition.default.arn
  desired_count = 1
  launch_type = "FARGATE"
}
