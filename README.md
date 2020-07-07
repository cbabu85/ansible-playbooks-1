# Requirements

* [ansible](https://www.ansible.com/resources/get-started) 2.9+ for Python 2
* [boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/quickstart.html) library for AWS interaction
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)


# Var Files
Configuration variables are stored in var files group_vars and host_vars
directories. Variables have a precedence on how they get applied. Most
variables are combined in a environment var file
(e.g. group_vars/demo-servers.yml).

Here is the order of precedence from least to greatest
(the last listed variables winning prioritization):

1. command line values (eg “-u user”)
2. role defaults
3. inventory file or script group vars
4. inventory group_vars/all
5. playbook group_vars/all
6. inventory group_vars/*
7. playbook group_vars/*
8. inventory file or script host vars
9. inventory host_vars/*
10. playbook host_vars/*
11. host facts / cached set_facts
12. play vars
13. play vars_prompt
14. play vars_files
15. role vars (defined in role/vars/main.yml)
16. block vars (only for tasks in block)
17. task vars (only for the task)
18. include_vars
19. set_facts / registered vars
20. role (and include_role) params
21. include params
22. extra vars (always win precedence)

Sensitive information files are encrypted using Ansible Vault.

## Ansible Vault
Sensitive information is securely stored via Ansible Vault. This feature of Ansible encrypts any file with AES-256bit encryption. This allows for storing encrypted files in a public repo (GitHub).

A best practice with Ansible Vault is to keep all variables in a single file (vault.yml) and reference them using an unencrypted file (all.yml) in order to be able to grep for variables without decrypting the vault every time.

Variable files are grouped by host groups that are defined in the hosts inventory file. For example all dpn-demo-servers have a `group_vars/dpn-demo-servers.yml` vault/var file where sensitive information is kept.

The process involves three basic commands:

### Encrypt a vault file (only done initially).
> ansible-vault create group_vars/vault.yml

### Edit encrypted variables
> ansible-vault edit group_vars/vault.yml

### Encrypting Unencrypted Files
> ansible-vault encrypt group_vars/otherfile.yml

### Re-key encrypted file (reset the password used to encrypt file)
> ansible-vault rekey group_vars/vault.yml

In order to run an Ansible playbook and decrypt the vault at runtime make sure to use the flag --ask-vault-pass
ansible-playbook site.yml --ask-vault-pass

## .ansible.cfg
It is advisable to keep an Ansible config file in your home directory to make use of Ansible simpler. A config file could look like this:
```
 [defaults]
  # Defines default inventory file.
 inventory = ~/aptrust/ansible-playbooks/hosts
 roles_path = ~/aptrust/ansible-playbooks/roles
 # Ask for vault_pass at every Ansible execution if no i
 # vault_password_file is defined.
 # ask_vault_pass = True
 # Defines vault password file to avoid password prompts and
 # unencrypt vault at playbook runtime.
 vault_password_file=~/aptrust/ansible-playbooks/.vault_password
 # Callback plugins that are executed at runtime.
 callback_plugins = ~/aptrust/ansible-playbooks/callback_plugins/
 filter_plugins = ~/aptrust/ansible-playbooks/filter_plugins/
 gathering = smart
 fact_caching = jsonfile
 fact_caching_connection = /tmp/ansible_factcache
 fact_caching_timeout = 31557600

 # Disables host_key checking when running plays on servers
 host_key_checking = False
 retry_files_enabled = False # Do not create them

[ssh_connection]
 ssh_args = -o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s -o ControlPath=~/.ssh/%h-%r
 # Performance improvement and workaround for
 # http://stackoverflow.com/questions/36646880/ansible-2-1-0-using-become-become-user-fails-to-set-permissions-on-temp-file
 pipelining = True
 ```

## Using Ansible for deployment

Note that if you are using virtualenv, you may have to set the ansible\_python\_interpreter in the playbook you want to run. For example, if you're using a virtualenv called `aptrust`, you would set this in your .yml playbook:

`ansible\_python\_interpreter: "~/.virtualenv/aptrust/bin/python"`


### Limit to certain hosts only
Some playbooks are applied to multiple hosts. For example pharos may be deployed in production, demo and local development environments. Therefore pharos servers may be grouped as `pharos-servers` in the inventory (hosts) file.
The pharos.yml play states,
```
- hosts: pharos-servers
  vars_files: ....
```
which applies it to _all_ pharos servers in the inventory:
```
[pharos-servers]
 apt-demo-repo hostname_name=apt-demo-repo hostname_fqdn=demo.aptrust.org host_eip=52.55.230.218 # Pharos Demo
 apt-demo-repo2 hostname_name=apt-demo-repo2 hostname_fqdn=demo.aptrust.org host_eip=34.196.207.37 # Pharos Demo2
 pharos ansible_user=vagrant hostname_name=pharos hostname_fqdn=pharos.aptrust.local host_eip=192.168.33.12
 apt-prod-repo2 hostname_name=apt-prod-repo2 hostname_fqdn=repo.aptrust.org host_eip=52.202.25.174 # Pharos Prod
 ```
 In order to limit the play to only one server you may run it like this:
 ` ansible-playbook pharos.yml --diff -b -l apt-demo-repo2`

### Tags
Some playbooks have tagged roles so one can only run a specific role from an otherwise complete playbook to provision and setup from scratch. For example the pharos.yml playbook here:
```
	 roles:
	   - {role: common, tags: common}
	   - {role: zzet.rbenv, tags: rbenv}
	   - {role: cd3ef.nginx-passenger, tags: [nginx, passenger, nginx-passenger]}
	   - {role: carlosbuenosvinos.ansistrano-deploy, tags: deploy}
	   - {role: aptrust.pharos, tags: pharos, deploy}
```
If you just want to deploy a change to the pharos repom, you wont need to run the whole playbook everytime. Instead just run
` ansible-playbook pharos.yml -t deploy -b`

### Example deployments for people who can't remember anything


| App | Staging | Demo | Production |  |
|-|-|-|-|-|
| Pharos | ansible-playbook pharos.staging.yml | ansible-playbook pharos.demo.yml | ansible-playbook pharos.production.yml | Deploy default (master) branch |
|  | ansible-playbook pharos.staging.yml -e git_branch=adifferentbranch | ~ | ~ | Deploy differnent branch of Pharos |
|  | ansible-playbook pharos.staging.yml -e git_version=03dfe9c | ~ | ~ | Deploy specific git-commit of Pharos |
| Exchange | ansible-playbook exchange.docker.yml -t deploy | ansible-playbook exchange.yml -t deploy | ansible-playbook exchange.yml -t deploy | Deploy default (master) branch |
|  | ansible-playbook exchange.docker.yml -t deploy -e ex_git_branch=custom-branch | ansible-playbook exchange.demo.yml -t deploy -e ex_git_branch=custom-branch | ansible-playbook exchange.production.yml -t deploy -e ex_git_branch=custom-branch |  |
|  |  | ansible-playbook exchange.demo.yml -t buildgo | ansible-playbook exchange.production.yml -t buildgo | Deploy exchange without restarting services: |
|  |  |  |  |  |
| Preserv | ansible-playbook preserv.staging.yml -t deploy | ansible-playbook preserv.demo.yml -t deploy | ansible-playbook preserv.production.yml -t deploy | Deploy default (master) branch |
|  | ansible-playbook preserv.staging.yml -e git_branch=adifferentbranch | ~ | ~ | Deploy custom branch of Preserv |
|  | ansible-playbook preserv.staging.yml -e git_version=03dfe9c | ~ | ~ | Deploy specific git-commit of Preserv |
|  |  |  |  |  |
