-- Concede permissões de CONNECT e SELECT para todas as tabelas no banco de dados MyDatabase para o usuário MyUser
USE MY_DB;
GRANT CONNECT, SELECT ON MY_DB TO [];

USE MY_DB
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE TO [];

USE master;
EXEC sp_grantlogin [];

USE msdb;
EXEC sp_addrolemember 'SQLAgentOperatorRole', [];
