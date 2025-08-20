resource "aws_ecr_repository" "ark_repo" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "ark_lifecycle_policy" {
  repository = aws_ecr_repository.ark_repo.name
  policy     = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 30 days"
        selection    = {
          tagStatus    = "untagged"
          countType    = "sinceImagePushed"
          countUnit    = "days"
          countNumber  = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

#### Permissions setup for ECS ####################################
resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.cluster_name}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

##### ECS Cluster ###############################################
resource "aws_ecs_cluster" "ark_cluster" {
  name = var.cluster_name
}

##### ECS Task Definition #######################################
resource "aws_ecs_task_definition" "ark_task" {
  family                   = var.container_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = "${aws_ecr_repository.ark_repo.repository_url}:${var.ecr_image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
    }
  ])
}

##### ECS Service ###############################################
resource "aws_ecs_service" "ark_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.ark_cluster.id
  task_definition = aws_ecs_task_definition.ark_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution_policy,
    aws_lb_target_group.app_tg,
    aws_subnet.private_a,
    aws_subnet.private_b,
    aws_ecs_task_definition.ark_task
  ]
}