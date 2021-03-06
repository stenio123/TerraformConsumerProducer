# TerraformProviderDemo
Demonstrates how Terraform Cloud Provider can be used to trigger execution of existing workspace and retrieve output values.


## Notes:

1. This is a specialized code that not only creates a workspace, but also deploys a module and populates the created workspace with outputs. If desired, this code can be used only to create workspace, without needing to call a module.

2. Module being called stores a secret in Vault. Once again, this code is custom using userpass as Vault Auth Method, however any other (like Active Directory) is supported.

3. This code assumes that Developer already registered in Terraform cloud and assigned a team. If that is not the case there is commented code that can also create and register new user and/or team in Terraform

4. You could opt to also populate workspace with AWS (or other cloud) credentials. However we decided not to do this here, relying on the Vault provider in the Consumer repo.

5. To be used in conjunction with https://github.com/stenio123/ServiceNowTerraformDemo

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
    },
    {
      "Effect": "Allow",
      "Action": "iam:*",
      "Resource": "*"
    }
  ]
}
EOF

vault read aws/creds/create-ec2

vault write aws/roles/create-rds \
    credential_type=iam_user \
    policy_document=-<<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCreateDBInstanceOnly",
            "Effect": "Allow",
            "Action": [
                "rds:CreateDBInstance"
            ],
            "Resource": [
                "arn:aws:rds:*:*:db:*",
                "arn:aws:rds:*:*:og:*",
                "arn:aws:rds:*:*:pg:*",
                "arn:aws:rds:*:*:subgrp:default"
            ]
        },
        {
          "Effect": "Allow",
          "Action": "iam:*",
          "Resource": "*"
        }
    ]
}
EOF

# Sample Vault server config
storage "file" {
  path    = "/home/ec2-user/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

ui = true
```