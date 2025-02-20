# Task definition
resource "aws_ecs_task_definition" "sunbird-cs-data-api_td" {
  family                   = "sunbird-cs-data-api-td-${local.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.ecs_api_cpu
  memory                   = local.ecs_api_memory
  execution_role_arn       = local.ecs_api_execution_role_arn
  task_role_arn            = local.ecs_api_task_role_arn

  container_definitions = jsonencode([
    {
      name                   = "sunbird-cs-data-api"
      image                  = local.ecs_api_erc_image
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
          awslogs-stream-prefix = "sunbird-cs-data"
          awslogs-create-group  = "true"
        }
      }

      environment = [
        {
          name  = "APP_ENV",
          value = "${local.env}"
        },
        {
          name  = "DB_HOST",
          value = local.DB_HOST[local.env]
        },
                {
          name  = "DB_PORT",
          value = "3306"
        },
        {
          name  = "DB_NAME",
          value = "veltra_tr"
        },
        {
          name  = "DB_USER",
          value = local.DB_USER[local.env]
        },
        {
          name  = "DB_PASSWORD",
          value = local.DB_PASSWORD[local.env]
        },
        {
          name  = "ENABLE_REDIS_CACHE",
          value = "1"
        },
        {
          name  = "REDIS_CACHE_MINUTE",
          value = "60"
        },
        {
          name  = "REDIS_ADDR",
          value = local.REDIS_ADDR[local.env]
        },
        {
          name  = "REDIS_DB",
          value = "0"
        },
        {
          name  = "API_HOST",
          value = local.API_HOST[local.env]
        },
        {
          name  = "API_VERSION_PATH",
          value = "/cs-data/v1"
        }
      ],
      mountPoints = [],
      volumesFrom = [],
    }
  ])
}

# Create target group for sunbird service
resource "aws_lb_target_group" "sunbird-cs-data-api_tg" {
  name        = "sunbird-cs-data-api-tg-${local.env}"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = local.ecs_vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_security_group" "sunbird-cs-data-api_svc_sg" {
  name        = local.ecs_api_sg_name
  description = local.ecs_api_sg_desc
  vpc_id      = local.ecs_vpc_id

  # Allow inbound from ALB
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    # TODO, should only allow access from sunbird service, not from ALB
    security_groups = [aws_security_group.sunbird-pricing_alb_sg.id]
  }
  # Adding additional security groups
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    security_groups = [
      "sg-05088c13ad7fca144"
    ]
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    security_groups = [
      "sg-0e340c5fef8fc8647"
    ]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    security_groups = [
      "sg-0c6f8b1dbdc022695"
    ]
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

# Create sunbird-cs-data-api service
resource "aws_ecs_service" "sunbird-cs-data-api_svc" {
  name                   = "sunbird-cs-data-api-svc-${local.env}"
  cluster                = aws_ecs_cluster.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.sunbird-cs-data-api_td.arn
  launch_type            = "FARGATE"
  desired_count          = local.ecs_api_desired_count
  enable_execute_command = true

  lifecycle {
    ignore_changes = [task_definition]
  }

  network_configuration {
    subnets         = local.ecs_api_subnets
    security_groups = [aws_security_group.sunbird-cs-data-api_svc_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.sunbird-cs-data-api_tg.arn
    container_name   = "sunbird-cs-data-api"
    container_port   = 8080
  }
}
