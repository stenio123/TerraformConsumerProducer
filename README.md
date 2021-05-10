# TerraformProviderDemo
Demonstrates how Terraform Cloud Provider can be used to trigger execution of existing workspace and retrieve output values.


## Notes:

1. This is a specialized code that not only creates a workspace, but also deploys a module and populates the created workspace with outputs. If desired, this code can be used only to create workspace, without needing to call a module.

2. Module being called stores a secret in Vault. Once again, this code is custom using userpass as Vault Auth Method, however any other (like Active Directory) is supported.

3. This code assumes that Developer already registered in Terraform cloud and assigned a team. If that is not the case there is commented code that can also create and register new user and/or team in Terraform