#For dev environment

module "dev" {
  source = "../modules/webserver"

  environment = {
    name            = "dev"
    network_prefix  = "10.0"
  }
}