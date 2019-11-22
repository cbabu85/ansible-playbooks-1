# Ansible 2.1 Vault issue:
There is a bug in Ansible 2.0.1 that prevents saving changes to an Ansible vault file. A fix requires changing an Ansible file as follows.
/usr/local/Cellar/ansible/2.0.1.0/libexec/lib/python2.7/site-packages/ansible/parsing/vault

https://github.com/ansible/ansible/commit/2ba4428424a97716e107ae36d79ef332439c36d1

# APTrust Ansible Config Files

These files are used to configure and manage servers and services for the
Academic Preservation Trust.

These are very early files as we are getting use to ansible and particularly
getting use to ansible best practices and they are prone to change often.

# Var Files
Var files are Ansible-conform stored in the group_vars and host_vars directories.
Sensitive information files are encrypted using Ansible Vault.

## Vagrant Setup

You can set up a local development environment to build, run, develop
and test playbooks. First, download and
install [Vagrant](https://docs.vagrantup.com/v2/installation/).

Copy the Vagrant file in this repository to the directory where you
want to install your Vagrant virtual machine. This documentation
assumes you are running Vagrant under ~/aptrust.

Note that the Vagrant file gives the virtual machine 8 processors and
2GB of RAM. You will need all of that RAM to build some of the Go
binaries if you stick with the 8 processor setting, because Go will
use 8 go-routines to build the source. If you want to use a more
lightweight VM, reduce the number of CPU cores and memory in
tandem. For example, you can do 2 cores and 1 GB of RAM.

You should be able to bring up your Vagrant virtual machine with this
command:

> vagrant up

The following command will print out settings that you can copy
directly into your ~/.ssh/config file. These settings can ease the
process of running your ansible playbooks against the VM.

> vagrant ssh-config

Now cd into the ansible-playbooks directory (the one that contains
this README file) and run the following:

> ansible-playbook vagrant.yml

The playbook will likely take 20 or more minutes to run, because it
does quite a bit of work.

You can connect to the Vagrant via SSH with this command:

> vagrant ssh

### Troubleshooting Your Vagrant Setup

If Ansible has trouble connecting to your Vagrant VM, try running:

> vagrant ssh-config

Note the path to the private key file in the vagrant output. Then run
this.

> ansible-playbook vagrant.yml -vvvv

In the command output, look at the private keys SSH tries to use. If
it does not match what the vagrant command printed, copy the output of
vagrant ssh-config into your ~/.ssh/config file.

If you have destroyed and re-created your Vagrant VM, the SSH
fingerprint of the new VM will not match the fingerprint of the old
VM. Ansible will fail to connect but will not give a meaningful
error. Open ~/.ssh/known_hosts and delete the entry for host
192.168.33.10, then try again.

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

Deploy Pharos to demo:

`ansible-playbook pharos.yml -l apt-demo`

Deploy Pharos to production:

`ansible-playbook pharos.yml -t deploy -b -l apt-prod-repo2`

Deploy exchange to demo:

`ansible-playbook exchange.yml --diff -t exchange -b -l apt-demo-services`

Deploy exchange to production:

`ansible-playbook exchange.yml --diff -t exchange -b -l apt-prod-services`

Deploy a custom branch of exchange to production:

`ansible-playbook exchange.yml --diff -t exchange -b -l apt-prod-services -e ex_git_branch=custom-branch`

Deploy exchange to production without restarting services:

`ansible-playbook exchange.yml -t buildgo -l apt-prod-services`

Deploy exchange to DPN demo:

`ansible-playbook exchange.yml --diff -t exchange -b -l dpn-demo2`

Deploy exchange to DPN production:

`ansible-playbook exchange.yml --diff -t exchange -b -l dpn-prod2`
