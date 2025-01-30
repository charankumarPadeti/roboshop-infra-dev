variable "common_tags" {
  type = map 
  default = {
    project = "Roboshop"
    Environment ="Dev"
    Terraform = "True"
  }
}


variable "project_name" {
  type = string
  default = "roboshop"
}

variable "environment" {
  type = string
  default = "dev"
}

# variable "mongodb_sg_ingress-rules" {
#   type = list 
#   default = [
#     {
#             description      = "Allow port 80"
#             from_port        = 80 # 0 means all ports 
#             to_port          = 80
#             protocol         = "tcp"
#             cidr_blocks      = ["0.0.0.0/0"]
#         },
#         {
#             description      = "Allow port 443"
#             from_port        = 443 # 0 means all ports 
#             to_port          = 443
#             protocol         = "tcp"
#             cidr_blocks      = ["0.0.0.0/0"]
#         }
#   ]
# }
