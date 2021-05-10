# AWS Variables
variable "aws_region" {
  description = "region to deploy resources in"
  default     = "us-east-2"
}

# Terraform Cloud Variables
variable "tfe_hostname" {
  description = "Terraofrm Cloud URL"
  default ="app.terraform.io"
}
variable "tfe_token" {
  description = "Terraform Cloud API token"
}
variable "organization" {
  description = "Terraofrm Cloud organization"
  default ="TFE_PoV"
}

# Module variables

variable "module_output1" {
  description = "Placeholder for a module output name"
  default ="db_ip_addr"
}
variable "module_output2" {
  description = "Placeholder for another module output name"
  default ="aws_secret_id"
}

# Workspace variables
variable "workspace_owner" {
  description = "User making request"
}

variable "team_id" {
  description = "Team which the user making request belongs to, for access in workspace through Terraform Cloud interface"
}

variable "vcs_identifier" {
  description = "Git repo to associate with workspace, in the format <organization>/<repository>"
}

variable "oauth_token" {
  description = "Git connection configured in Terraform"
}

variable "workspace_name" {
  description = "Workspace name"
}

variable "terraform_version" {
  description = "For this workspace"
  default = "0.15.3"
}