terraform {
  backend "s3" {
    bucket         = "terraform-state-feijao-com-arroz"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1" # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-state-feijao-com-arroz"
    #encrypt        = true
  }
}
module "haproxy_module" {
  source           = "./haproxy_module"
  name_app         = "apezinho_modular"
  name_app_network = "terraform_docker_network"
}