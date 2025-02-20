locals {
  env          = terraform.workspace

  # ECS API setting (sunbird-cs-data)
  #####################
  _conf_ecs_api_cpu = {
    dev   = "256"
    stage = "256"
    prod  = "1024"
  }

  ecs_api_cpu = local._conf_ecs_api_cpu[local.env]

  _conf_ecs_api_memory = {
    dev   = "512"
    stage = "512"
    prod  = "2048"
  }

  ecs_api_memory = local._conf_ecs_api_memory[local.env]

  _conf_ecs_api_execution_role_arn = {
    dev   = "arn:aws:iam::859648348429:role/currentsite-dev-web"
    stage = "arn:aws:iam::021124174008:role/sunbird-pricing-ecs-task"
    prod  = "arn:aws:iam::021124174008:role/sunbird-pricing-ecs-task" 
  }

  ecs_api_execution_role_arn = local._conf_ecs_api_execution_role_arn[local.env]

  _conf_ecs_api_task_role_arn = {
    dev   = "arn:aws:iam::859648348429:role/currentsite-dev-web"
    stage = "arn:aws:iam::021124174008:role/sunbird-pricing-ecs-task"
    prod  = "arn:aws:iam::021124174008:role/sunbird-pricing-ecs-task"
  }

  ecs_api_task_role_arn = local._conf_ecs_api_task_role_arn[local.env]

  _conf_ecs_api_erc_image = {
    dev   = "859648348429.dkr.ecr.ap-northeast-1.amazonaws.com/sunbird-cs-data-dev:latest"
    stage = "021124174008.dkr.ecr.ap-northeast-1.amazonaws.com/sunbird-cs-data-stage:latest"
    prod  = "021124174008.dkr.ecr.ap-northeast-1.amazonaws.com/sunbird-cs-data-prod:latest"
  }

  ecs_api_erc_image = local._conf_ecs_api_erc_image[local.env]

    _conf_admin_api_erc_image = {
    dev   = "859648348429.dkr.ecr.ap-northeast-1.amazonaws.com/sunbird-admin-api-dev:latest"
    stage = "021124174008.dkr.ecr.ap-northeast-1.amazonaws.com/sunbird-admin-api-stage:latest"
    prod  = "021124174008.dkr.ecr.ap-northeast-1.amazonaws.com/sunbird-admin-api-prod:latest"
  }

  admin_api_erc_image = local._conf_admin_api_erc_image[local.env]

    _conf_admin_erc_image = {
    dev   = "859648348429.dkr.ecr.ap-northeast-1.amazonaws.com/sunbird-admin-dev:latest"
    stage = "021124174008.dkr.ecr.ap-northeast-1.amazonaws.com/sunbird-admin-stage:latest"
    prod  = "021124174008.dkr.ecr.ap-northeast-1.amazonaws.com/sunbird-admin-prod:latest"
  }

  admin_erc_image = local._conf_admin_erc_image[local.env]


  _conf_ecs_api_log_group = {
    dev   = "/aws/ecs/sunbird-cs-data-task"
    stage = "/aws/ecs/sunbird-cs-data-task-stage"
    prod  = "/aws/ecs/sunbird-cs-data-task-prod"
  }

  ecs_api_log_group = local._conf_ecs_api_log_group[local.env]

  _conf_ecs_api_sg_name = {
    dev   = "sunbird-cs-data-svc-sg"
    stage = "sunbird-cs-data-svc-sg-stage"
    prod  = "sunbird-cs-data-svc-sg-prod"
  }
  
  ecs_api_sg_name = local._conf_ecs_api_sg_name[local.env]

  _conf_ecs_admin_api_sg_name = {
    dev   = "sunbird-admin-api-svc-sg-dev"
    stage = "sunbird-admin-api-svc-sg-stage"
    prod  = "sunbird-admin-api-svc-sg-prod"
  }

  ecs_admin_api_sg_name = local._conf_ecs_admin_api_sg_name[local.env]

  _conf_ecs_sunbird_admin_sg_name = {
    dev   = "sunbird-admin-svc-sg-dev"
    stage = "sunbird-admin-svc-sg-stage"
    prod  = "sunbird-admin-svc-sg-prod"
  }

  ecs_sunbird_admin_sg_name = local._conf_ecs_sunbird_admin_sg_name[local.env]

  _conf_ecs_api_sg_desc = {
    dev   = "Security group for sunbird-pricing that only allows access from ALB"                // TODO: the desc is wrong, should change it manually from aws console then only update here.
    stage = "Security group for sunbird-cs-data that only allows access from sunbird-pricing service" // TODO
    prod  = "Security group for sunbird-cs-data that only allows access from sunbird-pricing service" // TODO
  }

  ecs_api_sg_desc = local._conf_ecs_api_sg_desc[local.env]

    _conf_ecs_admin_api_sg_desc = {
    dev   = "Security group for sunbird-pricing that only allows access from ALB"                // TODO: the desc is wrong, should change it manually from aws console then only update here.
    stage = "Security group for sunbird-cs-data that only allows access from sunbird-pricing service" // TODO
    prod  = "Security group for sunbird-cs-data that only allows access from sunbird-pricing service" // TODO
  }

  ecs_admin_api_sg_desc = local._conf_ecs_admin_api_sg_desc[local.env]

    _conf_ecs_sunbird_admin_sg_desc = {
    dev   = "Security group for sunbird-admin that only allows access from ALB"                // TODO: the desc is wrong, should change it manually from aws console then only update here.
    stage = "Security group for sunbird-admin that only allows access from sunbird-pricing service" // TODO
    prod  = "Security group for sunbird-admin that only allows access from sunbird-pricing service" // TODO
  }

  ecs_sunbird_admin_sg_desc = local._conf_ecs_sunbird_admin_sg_desc[local.env]

  _conf_ecs_api_desired_count = {
    dev   = 3
    stage = 1
    prod  = 2
  }

  ecs_api_desired_count = local._conf_ecs_api_desired_count[local.env]

    _conf_ecs_admin_desired_count = {
    dev   = 1
    stage = 1
    prod  = 2
  }

  ecs_admin_desired_count = local._conf_ecs_admin_desired_count[local.env]


  _conf_ecs_api_subnets = {
    dev = [
      "subnet-08e7d7a106d678aae", # main-dev-private-ap-northeast-1c 10.1.200.0/24
      "subnet-0861b8b2f0bf40ff6"  # main-dev-private-ap-northeast-1d 10.1.201.0/24
    ]
    stage = [
      "subnet-0ed5509217dfbbed5", # main-stage-private-ap-northeast-1c
      "subnet-0aabc9e2a2aa50333" # main-stage-private-ap-northeast-1d 
    ]
    prod = [
      "subnet-002f0b7124aaebff2", // main-prod-private-ap-northeast-1c
      "subnet-0a1d4bffba764a85a"  // main-prod-private-ap-northeast-1d
    ]
  }

  ecs_api_subnets = local._conf_ecs_api_subnets[local.env]


  # ECS setting (sunbird-pricing)
  #####################
  _conf_ecs_vpc_id = {
    dev   = "vpc-05a9a74c32f4ce22e" // main-dev
    stage = "vpc-03eb78610728d47df" #main-stage                
    prod  = "vpc-086cf06d" #main (prod)
  }

  ecs_vpc_id = local._conf_ecs_vpc_id[local.env]

  _conf_ecs_ui_cpu = {
    dev   = "256"
    stage = "256"
    prod  = "256"
  }

  ecs_ui_cpu = local._conf_ecs_ui_cpu[local.env]

  _conf_ecs_ui_memory = {
    dev   = "512"
    stage = "512"
    prod  = "512"
  }

  ecs_ui_memory = local._conf_ecs_ui_memory[local.env]

  _conf_ecs_ui_execution_role_arn = {
    dev   = "arn:aws:iam::859648348429:role/currentsite-dev-web"
    stage = "arn:aws:iam::021124174008:role/sunbird-pricing-ecs-task"
    prod  = "arn:aws:iam::021124174008:role/sunbird-pricing-ecs-task"
  }

  ecs_ui_execution_role_arn = local._conf_ecs_ui_execution_role_arn[local.env]

  _conf_ecs_ui_task_role_arn = {
    dev   = "arn:aws:iam::859648348429:role/currentsite-dev-web"
    stage = "arn:aws:iam::021124174008:role/sunbird-pricing-ecs-task"
    prod  = "arn:aws:iam::021124174008:role/sunbird-pricing-ecs-task"
  }

  ecs_ui_task_role_arn = local._conf_ecs_ui_task_role_arn[local.env]

  _conf_ecs_ui_erc_image = {
    dev   = "859648348429.dkr.ecr.ap-northeast-1.amazonaws.com/sunbird-pricing-dev:latest"
    stage = "021124174008.dkr.ecr.ap-northeast-1.amazonaws.com/sunbird-pricing-stage:latest"
    prod  = "021124174008.dkr.ecr.ap-northeast-1.amazonaws.com/sunbird-pricing-prod:latest"
  }

  ecs_api_ui_image = local._conf_ecs_ui_erc_image[local.env]

  _conf_ecs_ui_log_group = {
    dev   = "/aws/ecs/sunbird-pricing-task"
    stage = "/aws/ecs/sunbird-pricing-task-stage"
    prod  = "/aws/ecs/sunbird-pricing-task-prod"
  }

  ecs_ui_log_group = local._conf_ecs_ui_log_group[local.env]

  _conf_ecs_alb_sg_name = {
    dev   = "sunbird-pricing-alb-sg"
    stage = "sunbird-pricing-alb-sg-stage"
    prod  = "sunbird-pricing-alb-sg-prod"
  }

  ecs_alb_sg_name = local._conf_ecs_alb_sg_name[local.env]

  _conf_ecs_ui_sg_name = {
    dev   = "sunbird-pricing-svc-sg"
    stage = "sunbird-pricing-svc-sg-stage"
    prod  = "sunbird-pricing-svc-sg-prod"
  }

  ecs_ui_sg_name = local._conf_ecs_ui_sg_name[local.env]

  _conf_ecs_lb_subnets = {
    dev = [
      "subnet-0fd894318f1ea3835", # main-dev-public-ap-northeast-1c
      "subnet-03e42d76c33c575a0"  # main-dev-public-ap-northeast-1d
    ]
    stage = [
      "subnet-0427f98b1310fa1d4", #main-stage-public-ap-northeast-1c
      "subnet-0bf5505e0b98ed9b2" #main-stage-public-ap-northeast-1d
    ]
    prod = [
      "subnet-07f9027cb26611fa2",
      "subnet-018a4767fc900f9c7"
    ]
  }

  ecs_lb_subnets = local._conf_ecs_lb_subnets[local.env]

  _conf_ecs_ui_desired_count = {
    dev   = 2
    stage = 1
    prod  = 1
  }

  ecs_ui_desired_count = local._conf_ecs_ui_desired_count[local.env]

  _conf_ecs_ui_subnets = {
    dev = [
      "subnet-08e7d7a106d678aae", # main-dev-private-ap-northeast-1c 10.1.200.0/24
      "subnet-0861b8b2f0bf40ff6"  # main-dev-private-ap-northeast-1d 10.1.201.0/24
    ]
    stage = [
      "subnet-0ed5509217dfbbed5", # main-stage-private-ap-northeast-1c
      "subnet-0aabc9e2a2aa50333" # main-stage-private-ap-northeast-1d     
    ]
    prod = [
      "subnet-002f0b7124aaebff2", // main-prod-private-ap-northeast-1c
      "subnet-0a1d4bffba764a85a"  // main-prod-private-ap-northeast-1d
    ]
  }

  ecs_ui_subnets = local._conf_ecs_ui_subnets[local.env]


  # Redis settings
  ################

  _conf_redis_sg_name = {
    dev   = "sunbird-pricing-redis-sg"
    stage = "sunbird-pricing-redis-sg-stage"
    prod  = "sunbird-pricing-redis-sg-prod"
  }
  
  redis_sg_name = local._conf_redis_sg_name[local.env]

  _conf_redis_allow_sg = {
    dev = [
      # allow access from efsmaint
      "sg-076679fce78eaef6d", // currentsite-efsmaint
    ],
    stage = [
      # allow access from efsmaint
      "sg-08cbe35dbd8bc8052"
    ],
    prod = [
      # allow access from efsmaint
      "sg-05b1ed3144b7bfc5c"
    ]
  }

  redis_allow_sg = local._conf_redis_allow_sg[local.env]

_conf_redis_allow_cidr_blocks = {
  dev = [
    # Lambda subnets. ex: for magpie-authorizer
    "172.16.0.0/16"
  ],
  stage = [
    # Lambda subnets. ex: for magpie-authorizer
    "10.2.0.0/16"
  ],
  prod = [
    # Lambda subnets. ex: for magpie-authorizer
    "10.0.7.0/24",
    "10.0.201.217/32",
    "10.0.200.157/32"
  ]
}

  redis_allow_cidr_blocks = local._conf_redis_allow_cidr_blocks[local.env]


  _conf_redis_node_type = {
    dev   = "cache.t4g.micro"
    stage = "cache.t4g.micro"
    prod  = "cache.t4g.small"
  }

  redis_node_type = local._conf_redis_node_type[local.env]

  _conf_redis_number_of_nodes = {
    dev   = 1
    stage = 1
    prod  = 1
  }

  redis_number_of_nodes = local._conf_redis_number_of_nodes[local.env]

  _conf_redis_engine_version = {
    dev   = "7.1"
    stage = "7.1"
    prod  = "7.1"
  }

  redis_engine_version = local._conf_redis_engine_version[local.env]

  _cong_redis_subnet_group_name = {
    dev   = "main-dev-cache"
    stage = "main-stage-cache"
    prod  = "main-cache"
  }

  redis_subnet_group_name = local._cong_redis_subnet_group_name[local.env]

  API_HOST = {
    dev = "https://api.dev.veltra.com"
    stage = "https://api.stage.veltra.com"
    prod  = "https://api.veltra.com"
    }

  REDIS_ADDR = {
    dev = "sunbird-pricing-redis-dev.sg2vrl.0001.apne1.cache.amazonaws.com:6379"
    stage = "sunbird-pricing-redis-stage.jzjydt.0001.apne1.cache.amazonaws.com:6379"
    prod  = "sunbird-pricing-redis-prod.jzjydt.0001.apne1.cache.amazonaws.com:6379"  
    }

  DB_HOST = {
    dev = "veltra-dev.cluster-ro-cqzknuwlvckx.ap-northeast-1.rds.amazonaws.com"
    stage = "veltra-stage.cluster-ro-cednzg2bccsp.ap-northeast-1.rds.amazonaws.com"
    prod  = "n-veltra-cluster.cluster-ro-cednzg2bccsp.ap-northeast-1.rds.amazonaws.com"  
    }
    
  CS_DATA = {
    dev = "https://api.dev.veltra.com/price/v1/query"
    stage = "https://api.stage.veltra.com/price/v1/query"
    prod  = "https://api.veltra.com/price/v1/query"
    }

  DB_USER = {
    dev = "veltra"
    stage = "veltrauser"
    prod  = "veltrauser"
    }

  DB_PASSWORD = {
    dev = "veltra123"
    stage = "W95zCa2v"
    prod  = "ghFKEm5z"
    }
    
  CS_DATA_GRAPHQL_ENDPOINT = {
    dev = "https://api.dev.veltra.com/cs-data/v1/query"
    stage = "https://api.stage.veltra.com/cs-data/v1/query"
    prod  = "https://graphql.api.prod.veltra.com/cs-data/v1/query"
    }  

  # ADMIN_CS_DATA_GRAPHQL_ENDPOINT = {
  #   dev = "https://api.dev.veltra.com/price/v1/query"
  #   stage = "https://api.stage.veltra.com/price/v1/query"
  #   prod  = "https://graphql.api.prod.veltra.com/price/v1/query"
  #   }
}