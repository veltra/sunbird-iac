resource "aws_security_group" "sunbird-pricing_redis_sg" {
  name        = local.redis_sg_name
  description = "Security group for sunbird-pricing redis that only allows access from sunbird-ui, sunbird-api services, currentsite-efsmaint"
  vpc_id      = local.ecs_vpc_id

  # Allow inbound from ALB
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.sunbird-pricing_svc_sg.id, aws_security_group.sunbird-cs-data-api_svc_sg.id]
  }

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = local.redis_allow_sg
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = local.redis_allow_cidr_blocks
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.redis_sg_name
  }
}


resource "aws_elasticache_cluster" "example" {
  cluster_id      = "sunbird-pricing-redis-${local.env}"
  engine          = "redis"
  node_type       = local.redis_node_type
  num_cache_nodes = local.redis_number_of_nodes
  engine_version  = local.redis_engine_version
  port            = 6379

  security_group_ids = [aws_security_group.sunbird-pricing_redis_sg.id]
  subnet_group_name  = local.redis_subnet_group_name

  apply_immediately = true
}
