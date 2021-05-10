# Based on the original code of https://github.com/AdamCavaliere/Producer-Repo

provider "tfe" {
  hostname = var.hostname
  token    = var.token
}

# Deploys desired module
module "db-module" {
  source  = "app.terraform.io/TFE_PoV/db-module/aws"
  version = "2.0.0"
}

# Configures user access

resource "tfe_team_organization_member" "developer" {
  team_id = "${tfe_team.developers.id}"
  organization_membership_id = "${tfe_organization_membership.developers.id}"
}

resource "tfe_team" "developers" {
  name         = "${var.use_case_name}-developers"
  organization = "${var.org}"
}

resource "tfe_team_access" "development-dev" {
  access       = "write"
  team_id      = "${tfe_team.developers.id}"
  workspace_id = "${tfe_workspace.development.id}"
}

resource "tfe_workspace" "development" {
  name         = var.workspace_name
  organization = var.organization
  auto_apply   = true
  queue_all_runs = false
  terraform_version = var.terraform_version

  vcs_repo {
    branch         = "master"
    identifier     = var.vcs_identifier
    oauth_token_id = var.oauth_token
  }
}


# Set variables
resource "tfe_variable" "development_aws_access_key" {
  key          = "AWS_ACCESS_KEY_ID"
  value        = "1234"
  category     = "env"
  sensitive     = true
  workspace_id = "${tfe_workspace.development.id}"
}
resource "tfe_variable" "module_output1" {
  key          = "Module Output 1"
  value        = [module.db-module.${var.module_output1}]
  category     = "terraform"
  sensitive     = false
  workspace_id = "${tfe_workspace.development.id}"
}
resource "tfe_variable" "workspace_var_development" {
  key      = "workspace_name"
  value    = var.workspace_name
  category = "terraform"

  workspace_id = "${tfe_workspace.development.id}"
}

resource "tfe_variable" "set_owner" {
  key          = "Owner"
  value        = var.workspace_owner
  category     = "env"
  workspace_id = "${tfe_workspace.development.id}"
}