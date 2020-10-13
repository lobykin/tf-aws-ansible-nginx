terraform {
  required_version = ">=0.13.4"
}

# Call the seed_module to build Nginx App
module "terraform" {
  source             = "./terraform"
}