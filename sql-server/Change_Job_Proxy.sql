USE msdb;

DECLARE @ProxyName NVARCHAR(128) = 'Proxy';  -- Substitua pelo nome do seu proxy
DECLARE @JobName NVARCHAR(128) = 'Job';      -- Substitua pelo nome do seu job

-- Identificar o ID do Proxy
DECLARE @ProxyID INT;
SELECT @ProxyID = proxy_id
FROM msdb.dbo.sysproxies
WHERE name = @ProxyName;

-- Atualizar os steps do job com o novo proxy
UPDATE s
SET s.proxy_id = @ProxyID
FROM msdb.dbo.sysjobsteps s
JOIN msdb.dbo.sysjobs j ON s.job_id = j.job_id
WHERE proxy_id in (1, 2)

-- Exibir resultados
SELECT
    j.name AS JobName,
    s.step_id,
    s.step_name,
    p.name AS ProxyName
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobsteps s ON j.job_id = s.job_id
JOIN msdb.dbo.sysproxies p ON s.proxy_id = p.proxy_id
--WHERE j.name = @JobName;
