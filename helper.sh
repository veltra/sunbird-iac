#!/bin/bash

DEFAULT_REGION="ap-northeast-1"
DEFAULT_PROFILE="default"

# ECS Services
DEFAULT_ECS_SERVICE_PRIVATE="sunbird-cs-data"
DEFAULT_ECS_SERVICE_PUBLIC="sunbird-pricing"

# ALB
DEFAULT_ALB_NAME="currentiste-alb"
DEFAULT_ALB_PORT="443"

# App Settings
DEFAULT_APP_ENV="dev"
DEFAULT_APP_DEBUG="true"
DEFAULT_APP_PORT="5000"

SRC_DIR="${PWD}"
BACKEND_BUCKET_PREFIX="sunbird-iac-terraform-"
ENV_LIST="dev stage prod"

function _usage {
  cat <<END_OF_CONTENT
Usage:
  ./helper.sh <commands>

Commands:
  start        Create env.{env}.ini file and Terraform workspace.
  required arguments:
  dev          Create env.dev.ini file for dev AWS environment.
  stage        Create env.stage.ini file for stage AWS environment.
  prod         Create env.prod.ini file for prod AWS environment.
  optional arguments:
  -y, --yes    Create env.{env}.ini file with default value.
    
  tf           Execute Terraform-related commands.
    
  help         Show this help message.
END_OF_CONTENT
}

function _init {
  current_env=$1
  echo "Setting up environment file for ${current_env}..."

  aws_region=$DEFAULT_REGION
  aws_profile=$DEFAULT_PROFILE
  ecs_service_private=$DEFAULT_ECS_SERVICE_PRIVATE
  ecs_service_public=$DEFAULT_ECS_SERVICE_PUBLIC
  alb_name=$DEFAULT_ALB_NAME
  alb_port=$DEFAULT_ALB_PORT
  app_env=$DEFAULT_APP_ENV
  app_debug=$DEFAULT_APP_DEBUG
  app_port=$DEFAULT_APP_PORT

  _create_env_file $current_env $aws_region $aws_profile "" "" "" \
    $ecs_service_private $ecs_service_public $alb_name $alb_port $app_env $app_debug $app_port
}

function _create_env_file {
  current_env=$1
  aws_region=$2
  aws_profile=$3
  redis_host=$4
  redis_port=$5
  redis_namespace=$6
  ecs_service_private=$7
  ecs_service_public=$8
  alb_name=$9
  alb_port=${10}
  app_env=${11}
  app_debug=${12}
  app_port=${13}

  cat <<EOF >${SRC_DIR}/env.${current_env}.ini
AWS_REGION=${aws_region}
AWS_PROFILE=${aws_profile}

# ECS Services
ECS_SERVICE_PRIVATE=${ecs_service_private}
ECS_SERVICE_PUBLIC=${ecs_service_public}

# ALB
ALB_NAME=${alb_name}
ALB_PORT=${alb_port}

# Application Settings
APP_ENV=${app_env}
APP_DEBUG=${app_debug}
APP_PORT=${app_port}
EOF

  echo "Environment file for ${current_env} created at ${SRC_DIR}/env.${current_env}.ini"
}

function _start {
  if [ -z "$1" ]; then
    echo "Environment name is required (e.g., dev, stage, prod)."
    exit 1
  fi

  _init $1
}

function _tf {
  current_env=$1
  if [ ! -f "${SRC_DIR}/env.${current_env}.ini" ]; then
    echo "Environment file env.${current_env}.ini not found. Run './helper.sh start ${current_env}' first."
    exit 1
  fi

  source "${SRC_DIR}/env.${current_env}.ini"

terraform init \
  -backend-config="bucket=sunbird-terraform-${current_env}" \
  -backend-config="region=${AWS_REGION}" \
  -backend-config="profile=${AWS_PROFILE}" \
  -backend-config="key=state/${current_env}/terraform.tfstate" \
  -force-copy -reconfigure

  terraform workspace select ${current_env} || terraform workspace new ${current_env}

  terraform "${@:2}"
}

function _main {
  if [ "$#" -eq 0 ]; then
    _usage
    exit 0
  fi

  case "$1" in
  start)
    _start $2
    ;;
  tf)
    _tf $2 ${@:3}
    ;;
  help)
    _usage
    ;;
  *)
    echo "Unknown command: $1"
    _usage
    exit 1
    ;;
  esac
}

# Call the main function
_main "$@"