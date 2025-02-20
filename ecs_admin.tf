# Task definition
resource "aws_ecs_task_definition" "sunbird-admin_td" {
  family                   = "sunbird-admin-td-${local.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.ecs_api_cpu
  memory                   = local.ecs_api_memory
  execution_role_arn       = local.ecs_api_execution_role_arn
  task_role_arn            = local.ecs_api_task_role_arn

  container_definitions = jsonencode([
    {
      name                   = "sunbird-admin"
      image                  = local.admin_erc_image
      enable_execute_command = true
      portMappings = [
        {
          containerPort = 8080
          # hostPort      = 0 # 0 is not needed and can be omitted
        }
      ]
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = local.ecs_api_log_group
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "sunbird-admin"
          awslogs-create-group  = "true"
        }
      }

      environment = [
        {
          name  = "APP_ENV",
          value = "${local.env}"
        },
        {
          name  = "root",
          value = "/usr/share/nginx/html"
        },
        {
          name  = "index",
          value = "index.html index.htm"
        },
        {
          name  = "try_files",
          value = "$uri /index.html"
        },
        {
          name  = "server_name",
          value = "localhost"
        }
      ],
      mountPoints = [],
      volumesFrom = [],
    }
  ])
}

# Create target group for sunbird admin
resource "aws_lb_target_group" "sunbird-admin_tg" {
  name        = "sunbird-admin-tg-${local.env}"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = local.ecs_vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_security_group" "sunbird-admin_svc_sg" {
  name        = local.ecs_sunbird_admin_sg_name
  description = local.ecs_admin_api_sg_desc
  vpc_id      = local.ecs_vpc_id

  # Allow inbound from ALB
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    # TODO, should only allow access from sunbird service, not from ALB
    security_groups = [aws_security_group.sunbird-pricing_alb_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = local.ecs_api_sg_name
  }
}

# Create sunbird-admin service
resource "aws_ecs_service" "sunbird-admin_svc" {
  name                   = "sunbird-admin-svc-${local.env}"
  cluster                = aws_ecs_cluster.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.sunbird-admin_td.arn
  launch_type            = "FARGATE"
  desired_count          = local.ecs_admin_desired_count
  enable_execute_command = true

  lifecycle {
    ignore_changes = [task_definition]
  }

  network_configuration {
    subnets         = local.ecs_api_subnets
    security_groups = [aws_security_group.sunbird-admin_svc_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.sunbird-admin_tg.arn
    container_name   = "sunbird-admin"
    container_port   = 8080
  }
}
