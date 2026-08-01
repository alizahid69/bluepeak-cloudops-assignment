provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(var.common_tags, {
      ManagedBy = "Terraform"
      Component = "TerraformBackend"
    })
  }
}
