CREATE ROLE readaccess;
GRANT USAGE ON SCHEMA public TO readaccess;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readaccess;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readaccess;
CREATE USER {{pharos_db_ro_user}} WITH PASSWORD {{pharos_db_ro_pwd}};
GRANT readaccess TO {{pharos_db_ro_user}};

