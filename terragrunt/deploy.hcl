remote_state {
    backend = "s3"
    generate = {
        path      = "backend.tf"
        if_exists = "overwrite"
    }
    config = {
        bucket         = "snapit-iac-tfstate"
        key            = "infra/infra-base/infra.tfstate"
        region         = "us-east-1"
        encrypt        = true
        dynamodb_table = "snapit-tfstate-lock"
    }
}

terraform {
  source = "../"

  extra_arguments "conditional_vars" {
    commands = [
      "apply",
      "plan",
      "destroy",
      "import",
      "validate",
      "refresh",
      "import",
      "state",
    ]

    required_var_files = [
      "./tfvars/deploy.tfvars",
      "./tfvars/endpoint_config.tfvars"
    ]
  }
}