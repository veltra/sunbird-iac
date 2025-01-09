# resource "aws_ssm_parameter" "DB_PORT" {
#   name        = "/sunbird-pricing/${local.env}/DB_PORT"
#   description = "api-pricing parameter"
#   type        = "String"
#   value       = "3306"
# }

# resource "aws_ssm_parameter" "DB_NAME" {
#   name        = "/sunbird-pricing/${local.env}/DB_NAME"
#   description = "api-pricing parameter"
#   type        = "String"
#   value       = "veltra_tr"
# }

# resource "aws_ssm_parameter" "DB_USER" {
#   name        = "/sunbird-pricing/${local.env}/DB_USER"
#   description = "api-pricing parameter"
#   type        = "String"
#   value       = "veltrauser"
# }

# resource "aws_ssm_parameter" "DB_PASSWORD" {
#   name        = "/sunbird-pricing/${local.env}/DB_PASSWORD"
#   description = "api-pricing parameter"
#   type        = "String"
#   value       = "ghFKEm5z"
# }

# resource "aws_ssm_parameter" "ENABLE_REDIS_CACHE" {
#   name        = "/sunbird-pricing/${local.env}/ENABLE_REDIS_CACHE"
#   description = "api-pricing parameter"
#   type        = "String"
#   value       = "1"
# }

# resource "aws_ssm_parameter" "REDIS_CACHE_MINUTE" {
#   name        = "/sunbird-pricing/${local.env}/REDIS_CACHE_MINUTE"
#   description = "api-pricing parameter"
#   type        = "String"
#   value       = "60"
# }

# resource "aws_ssm_parameter" "REDIS_ADDR" {
#   name        = "/sunbird-pricing/${local.env}/REDIS_ADDR"
#   description = "api-pricing parameter"
#   type        = "String"
#   value       = local.redis_addrs[local.env]
# }

# resource "aws_ssm_parameter" "REDIS_DB" {
#   name        = "/sunbird-pricing/${local.env}/REDIS_DB"
#   description = "api-pricing parameter"
#   type        = "String"
#   value       = "0"
# }

# resource "aws_ssm_parameter" "API_HOST" {
#   name        = "/sunbird-pricing/${local.env}/API_HOST"
#   description = "api-pricing parameter"
#   type        = "String"
#   value       = local.API_HOST[local.env]
# }

# resource "aws_ssm_parameter" "DB_HOST" {
#   name        = "/sunbird-pricing/${local.env}/DB_HOST"
#   description = "api-pricing parameter"
#   type        = "String"
#   value       = local.DB_HOST[local.env]
# }

# resource "aws_ssm_parameter" "CS_DATA" {
#   name        = "/sunbird-pricing/${local.env}/CS_DATA"
#   description = "api-pricing parameter"
#   type        = "String"
#   value       = local.CS_DATA[local.env]
# }