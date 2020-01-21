## Definition
This role defines new APTrust members and sets up infrastructure (AWS and Pharos) and members. The goal is to ramp up a new member and not require manual GUI interaction.

The term members is chosen to apply to academic institutions as well as cultural heritage organizations.

It provides the following tasks:
 1. Create S3 buckets
 2. Create IAM Group
 3. Create IAM Users
 4. Setup an IAM policy to manage access to S3 buckets
 5. Apply the IAM inline policy to the groups (test/staging/prod)
 6. Setup logging of S3 buckets to aptrust.s3.logs bucket
 7. Setup lifecycle rules of S3 buckets

This playbook utilizes encrypted data structures in the

```group_vars/members/[inst_id].yml```

### Sustaining Members
inst_id: The ID the institution goes by. Usually organized by domain names,
e.g. UVa -> virginia
inst_id_suffix: edu|org|etc
inst_type: member, sub, subs
// Member: Sustaining member account.
// Sub accounts: Sub accounts can be schools/departments within institutions,
//              at UVa the Law Library would be a sub-account and hence go by
//              viul.virginia.edu and have their own IAM groups, users and buckets.

### Subscriber accounts
#### Example subscriber/sub-account
inst_name: "Full name of entity"
inst_member: virginia # Self referencing if memberfile is sust. APT member
inst_users: #List of user names, format: firstname.lastname
inst_admin: #List of user names, repeats one or more user names from inst_users.

## EXAMPLE
```
virginia.yml:
inst_id: virginia
inst_type: member
inst_member: virginia # Self referencing if memberfile is sust. APT member
```
Note: Each institution is in a separate encrypted group var file like
```group_vars/members/virginia.yml```
```group_vars/members/vt.yml```
``` etc.```

To run this playbook for a particular member, change the inst_id and inst_suffix in the vars below.

<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEzMTEyMzg1MDNdfQ==
-->
