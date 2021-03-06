# Retrieve AWS API keys from Vault
provider "vault" {
  address = var.vault_url
  auth_login {
    path = "auth/userpass/login/${var.vault_username}"

    parameters = {
      password = var.vault_userpass
    }
  }
}

data "vault_aws_access_credentials" "creds" {
  backend = var.vault_aws_secret_path
  role    = var.vault_aws_role
}

provider "aws" {
  access_key = "${data.vault_aws_access_credentials.creds.access_key}"
  secret_key = "${data.vault_aws_access_credentials.creds.secret_key}"
}


# Based on the original code of https://github.com/AdamCavaliere/Producer-Repo

provider "tfe" {
  hostname = var.tfe_hostname
  token    = var.tfe_token
}

# Deploys desired module
module "db-module" {
  source  = "app.terraform.io/TFE_PoV/db-module/aws"
  vault_url = var.vault_url
  vault_username = var.vault_username
  vault_userpass = var.vault_userpass
  # Just use latest version
  #version = "3.0.0"
}

# Configures user access

/*
resource "tfe_team_organization_member" "developer" {
  team_id = "${tfe_team.developers.id}"
  organization_membership_id = "${tfe_organization_membership.developers.id}"
}

resource "tfe_team" "developers" {
  name         = "${var.use_case_name}-developers"
  organization = "${var.org}"
}
**/

resource "tfe_team_access" "development-dev" {
  permissions   {
    runs = "apply"
    variables = "write"
    state_versions= "none"
    sentinel_mocks = "none"
    workspace_locking = "false"
  }
  team_id      = var.team_id #"${tfe_team.developers.id}"
  workspace_id = "${tfe_workspace.development.id}"
}

resource "tfe_workspace" "development" {
  name         = var.workspace_name
  organization = var.organization
  auto_apply   = false
  terraform_version = var.terraform_version

  vcs_repo {
    # branch         = "master"
    identifier     = var.vcs_identifier
    oauth_token_id = var.oauth_token
  }
}


# Set variables
resource "tfe_variable" "development_aws_access_key" {
  key          = "AWS_ACCESS_KEY_ID"
  value        = ""
  category     = "env"
  sensitive     = false
  workspace_id = "${tfe_workspace.development.id}"
}
resource "tfe_variable" "development_aws_secret_key" {
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = ""
  category     = "env"
  sensitive     = false
  workspace_id = "${tfe_workspace.development.id}"
}
resource "tfe_variable" "development_aws_session_token" {
  key          = "AWS_SESSION_TOKEN"
  value        = ""
  category     = "env"
  sensitive     = false
  workspace_id = "${tfe_workspace.development.id}"
}
resource "tfe_variable" "development_aws_region" {
  key          = "AWS_REGION"
  value        = "us-east-1"
  category     = "env"
  sensitive     = false
  workspace_id = "${tfe_workspace.development.id}"
}
resource "tfe_variable" "module_output1" {
  key          = "db_ip_addr"
  value        = module.db-module.db_ip_addr
  category     = "terraform"
  sensitive     = false
  workspace_id = "${tfe_workspace.development.id}"
}
resource "tfe_variable" "module_output2" {
  key          = "vault_secret_path"
  value        = module.db-module.vault_secret_path
  category     = "terraform"
  sensitive     = false
  workspace_id = "${tfe_workspace.development.id}"
}
resource "tfe_variable" "vault_url" {
  key          = "vault_url"
  value        = var.vault_url
  category     = "terraform"
  sensitive     = false
  workspace_id = "${tfe_workspace.development.id}"
}
resource "tfe_variable" "vault_username" {
  key          = "vault_username"
  value        = ""
  category     = "terraform"
  sensitive     = false
  workspace_id = "${tfe_workspace.development.id}"
}
resource "tfe_variable" "vault_userpass" {
  key          = "vault_userpass"
  value        = ""
  category     = "terraform"
  sensitive     = true
  workspace_id = "${tfe_workspace.development.id}"
}

resource "tfe_variable" "set_owner" {
  key          = "Owner"
  value        = var.workspace_owner
  category     = "env"
  workspace_id = "${tfe_workspace.development.id}"
}
resource "tfe_variable" "vault_aws_role" {
  key          = "vault_aws_role"
  value        = ""
  category     = "terraform"
  sensitive     = false
  workspace_id = "${tfe_workspace.development.id}"
}
resource "tfe_variable" "vault_aws_secret_path" {
  key          = "vault_aws_secret_path"
  value        = ""
  category     = "terraform"
  sensitive     = false
  workspace_id = "${tfe_workspace.development.id}"
}
