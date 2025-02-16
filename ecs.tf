resource "aws_ecs_cluster" "ecs_cluster" {
  name = "sunbird-pricing-${local.env}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Task definition
resource "aws_ecs_task_definition" "sunbird-pricing_td" {
  family                   = "sunbird-pricing-td-${local.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = local.ecs_ui_cpu
  memory                   = local.ecs_ui_memory
  # TODO: need to create execution role and task role
  # execution_role_arn       = "arn:aws:iam::859648348429:role/sunbird-pricing-dev"
  # task_role_arn            = "arn:aws:iam::859648348429:role/ecsTaskExecutionRole"
  execution_role_arn = local.ecs_ui_execution_role_arn
  task_role_arn      = local.ecs_ui_task_role_arn

  container_definitions = jsonencode([
    {
      name                   = "sunbird-pricing"
      image                  = local.ecs_api_ui_image
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
          awslogs-group         = local.ecs_ui_log_group
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "sunbird-pricing"
          awslogs-create-group  = "true"
        }
      }
environment = [
  {
    name  = "APP_ENV"
    value = "${local.env}"
  },
  {
    name  = "CS_DATA_GRAPHQL_ENDPOINT"
    value = local.CS_DATA_GRAPHQL_ENDPOINT[local.env]
  },
  {
    name      = "API_HOST"
    value = local.API_HOST[local.env]
  },
  {
    name  = "API_VERSION_PATH",
    value = "/price/v1"
  }
]
 }
  ])
}

resource "aws_security_group" "sunbird-pricing_alb_sg" {
  name        = local.ecs_alb_sg_name
  description = "Security group for ALB that allows web traffic"
  vpc_id      = local.ecs_vpc_id

  # Allow inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    # Allow inbound HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.ecs_alb_sg_name
  }
}

resource "aws_security_group" "sunbird-pricing_svc_sg" {
  name        = local.ecs_ui_sg_name
  description = "Security group for sunbird-pricing that only allows access from ALB"
  vpc_id      = local.ecs_vpc_id

  # Allow inbound from ALB
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
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
    Name = local.ecs_ui_sg_name
  }
}

# Create application load balancer for sunbird-pricing and sunbird-cs-data services
resource "aws_lb" "sunbird-pricing_alb" {
  name               = "sunbird-pricing-alb-${local.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sunbird-pricing_alb_sg.id]
  subnets            = local.ecs_lb_subnets
}

# Create target group for sunbird-pricing service
resource "aws_lb_target_group" "sunbird-pricing_tg" {
  name        = "sunbird-pricing-tg-${local.env}"
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

resource "aws_lb_listener" "sunbird-pricing_alb_listener" {
  load_balancer_arn = aws_lb.sunbird-pricing_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create sunbird-pricing service
resource "aws_ecs_service" "sunbird-pricing_svc" {
  name                   = "sunbird-pricing-svc-${local.env}"
  cluster                = aws_ecs_cluster.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.sunbird-pricing_td.arn
  launch_type            = "FARGATE"
  desired_count          = local.ecs_ui_desired_count
  enable_execute_command = true

  lifecycle {
    ignore_changes = [task_definition]
  }

  network_configuration {
    subnets         = local.ecs_ui_subnets
    security_groups = [aws_security_group.sunbird-pricing_svc_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.sunbird-pricing_tg.arn
    container_name   = "sunbird-pricing"
    container_port   = 8080
  }
}
