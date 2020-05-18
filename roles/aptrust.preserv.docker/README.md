APTrust Preservation Services
===

This role installs and manages Preservation Services for ingest and restore of APTrust repository objects.

Workflow:
- Creates default directories on EC2 instance (/srv/docker/preservation-services)
- Checks out the latest version of the code repository into default directory
- Updates .env.docker in default directory with values according to environment
- Runs docker-compose up to start services

Requirements
------------
This role is designed to be deployed on a Ubuntu Linux system.
The only system dependency is the Docker deamon.

Role Variables
--------------

See defaults/main.yml

All variables default to local development values. For deployment on demo or production systems the variables have to be overwritten using group_vars or host_vars.

Dependencies
------------

See playbook allservers.docker.yml

Example Playbook
----------------
-   hosts: pharos
    vars_files:
        - "group_vars/vault.yml"

    vars:
        playbook_name: Preservation Services

    roles:
      - {role: aptrust.preserv.docker, tags: preserv}

Example calls
--------------

License
-------

MIT
