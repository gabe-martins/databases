USE master
GO

SELECT
  database_id [ID],
  name [Banco],
  compatibility_level [Versao],
  recovery_model_desc [Model]
FROM sys.databases
GO

ALTER DATABASE SSISDB SET RECOVERY SIMPLE
GO

use SSISDB
GO

sp_helpfile
GO

DBCC SHRINKFILE ('log', 1)
GO