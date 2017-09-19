APTrust Exchange Go Services
===

A role which installs and manages Exchange Go Services for ingest and restore of APTrust repository objects.

To limit deployment to ingest, restore or ingest&restore services the role can be called with `ansible-playbook exchange.yml -e ex_services=(all|ingest|restore)`. The default is to deploy all services on a single server. The default variables keep a nested list of Go services for each purpose.

After the github repo has been pulled and Go apps have been compiled, the environment-dependent (development/demo/production) configuration is being updated according to default values and go_env setting.

Some of the configuration has to be kept in Ansible as many variables create dependencies to other services.

At last, supervisor configuration is being written according to the list of edeployed services. All services are grouped under `exchange` (i.e. exchange:apt_fetch` and therefore have to be called that way to be restarted or checked on status.

Run the full playbook with `ansible-playbook exchange.yml --diff -l server1`
Only update the code (no restarting of services) `ansible-playbook exchange.yml --diff -l server1 -t buildgo`

Requirements
------------
This role is designed to be deployed on a Ubuntu Linux system.
It requires supervisor, nsq and golang to be installed.

Role Variables
--------------

See defaults/main.yml

All variables default to local development values. For deployment on demo or production systems the variables have to be overwritten using group_vars or host_vars.

Dependencies
------------

futurice.supervisor
sansible.golang
retr0h.nsq


Example Playbook
----------------
-   hosts: pharos
    vars_files:
        - "group_vars/vault.yml"

    environment: "{{go_env}}"
    vars:
        playbook_name: exchange
        GO_ENV: 'demo'
        golang_workspace_user: "{{system_default_user}}"

    roles:
      - {role: common, tags: common}
      - {role: futurice.supervisor, tags: supervisor}
      - {role: sansible.golang, tags: golang}
      - {role: retr0h.nsq, tags: nsq}
      - {role: aptrust.exchange, tags: exchange}

License
-------

MIT
