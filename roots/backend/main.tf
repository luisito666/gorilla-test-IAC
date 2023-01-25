provider "aws" {
  region  = var.region
}

provider "random" {

}


terraform {
  backend "s3" {
    bucket  = "terraform-states-vps-hosting-netluna"
    key     = "backend.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

module "backend" {
  source = "../../modules/backend"

  region            = var.region
  subnet_cidr_block = var.subnet_cidr_block
}
