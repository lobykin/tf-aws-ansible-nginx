terraform {
  required_version = ">=0.13.4"
  backend "s3" {
    bucket         = var.s3_bucket_name
    key            = var.state_key
    region         = var.region
    dynamodb_table = var.dynamo_db_table_name
    encrypt        = true
    }
}

# Call the seed_module to build Nginx App
module "terraform" {
  source             = "./terraform"
}