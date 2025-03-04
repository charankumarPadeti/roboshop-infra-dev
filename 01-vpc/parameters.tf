resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project_name}/${var.environment}/vpc_id"   #Search in Google aws terraform parameter store
  type  = "String"
  value = module.Roboshop.vpc_id
}

resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/public_subnet_ids"
  type  = "StringList"                                                   
  value = join(",", module.Roboshop.public_subnet_ids)                
                                                                                  
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/private_subnet_ids"
  type  = "StringList"
  value = join(",", module.Roboshop.private_subnet_ids)
}

resource "aws_ssm_parameter" "database_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/database_subnet_ids"
  type  = "StringList"
  value = join(",", module.Roboshop.database_subnet_ids)
}

resource "aws_ssm_parameter" "rabbitmq_user" {
  name  = "/${var.project_name}/${var.environment}/rabbitmq_user"
  type  = "SecureString"
  value = "roboshop"
}

resource "aws_ssm_parameter" "rabbitmq_password" {
  name  = "/${var.project_name}/${var.environment}/rabbitmq_password"
  type  = "SecureString"
  value = "roboshop123"
}

resource "aws_ssm_parameter" "mysql" {
  name  = "/${var.project_name}/${var.environment}/mysql_root_pass"
  type  = "SecureString"
  value = "RoboShop@1"
}

# resource "aws_ssm_parameter" "database_subnet_ids" {
#   name  = "/${var.project_name}/${var.environment}/database_subnet_ids"
#   type  = "StringList"
#   value = join(",", module.Roboshop.database_subnet_ids)
# }

# output "public_subnet_ids" {
#   value = module.Roboshop.public_subnets_ids
# }