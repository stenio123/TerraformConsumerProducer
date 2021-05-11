# TerraformProviderDemo
Demonstrates how Terraform Cloud Provider can be used to trigger execution of existing workspace and retrieve output values.


## Notes:

1. This is a specialized code that not only creates a workspace, but also deploys a module and populates the created workspace with outputs. If desired, this code can be used only to create workspace, without needing to call a module.

2. Module being called stores a secret in Vault. Once again, this code is custom using userpass as Vault Auth Method, however any other (like Active Directory) is supported.

3. This code assumes that Developer already registered in Terraform cloud and assigned a team. If that is not the case there is commented code that can also create and register new user and/or team in Terraform

## Vault Requirements
For this demo, you need an existing Vault with the following
- userpass auth method enabled
- Two users, 'manager' and 'developer'
- Each user with appropriate permissions. For demo purposes, you can use
```
## Auth Method
# admin-policy.hcl
path "*" {
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

vault write auth/userpass/users/developer  password=123  policies=admin
vault write auth/userpass/users/manager  password=123  policies=admin

## Secret Engine
vault secrets enable kv -version=1 -path=secret


vault secrets enable aws

vault write aws/config/root \
    access_key=KEY \
    secret_key=SECRET \
    region=us-east-1

vault write aws/roles/create-ec2 \
    credential_type=iam_user \
    policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*"
    }
  ]
}
EOF

vault read aws/creds/create-ec2

storage "file" {
  path    = "/home/ec2-user/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

ui = true
```