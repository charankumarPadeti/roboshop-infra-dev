data "aws_ssm_parameter" "vpc_id" {
  name ="/${var.project_name}/${var.environment}/vpc_id"  #Search google data source ssm parameter.
}

data "aws_vpc" "default" {

  default = true
  
}
# data "aws_ssm_parameter" "vpc_id" {
#   name ="/${var.project_name}/${var.environment}/vpc_id"
# }

# data "aws_ssm_parameter" "vpc_id" {
#   name ="/${var.project_name}/${var.environment}/vpc_id"
# }