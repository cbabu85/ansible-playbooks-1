## Definition
This role defines creates APTrust infrastructure.

 - Create S3 preservation buckets
 - Create Wasabi preservation buckets
 - Create S3 Glacier buckets
 - Enables default encryption
 - Blocks S3 public access by default
 - Setup S3 Lifecycle policies for Deep Glacier
 - Setup Preservation services users and group
 - Setup bucket policies to limit preservation services user access

This playbook utilizes encrypted data structures in the

```group_vars/aws/vars.yml```
```group_vars/aws/vault.yml```


Do use this role when updating AWS infrastrucutre that affects ingest/restore
infrastructure which includes IAM policies to control access.

Do NOT use this role to setup AWS infrastructure for members/institutions. See
aptrust.members role.
