--------------------------- EXECUÇÃO DE JOBS -----------------------------------
SELECT 
    J.NAME AS 'NOME DO JOB',
    CASE
        WHEN H.RUN_STATUS = 0 THEN 'FALHA'
        ELSE 'SUCESSO'
    END AS 'STATUS',
	MSDB.DBO.AGENT_DATETIME(RUN_DATE, RUN_TIME) AS 'ÚLTIMA EXECUÇÃO',
	CONVERT(TIME, STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(6), H.RUN_DURATION), 6), 3, 0, ':'), 6, 0, ':')) AS 'TEMPO DE EXECUÇÃO',
    CASE
        WHEN S.NEXT_RUN_DATE IS NOT NULL AND S.NEXT_RUN_TIME IS NOT NULL THEN
            CONVERT(DATETIME, CONVERT(CHAR(8), S.NEXT_RUN_DATE, 112) + ' ' +
            STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(6), S.NEXT_RUN_TIME), 6), 3, 0, ':'), 6, 0, ':'), 120)
        ELSE
            NULL
    END AS 'PRÓXIMA EXECUÇÃO'
FROM MSDB.DBO.SYSJOBS AS J
INNER JOIN MSDB.DBO.SYSJOBSCHEDULES AS S ON J.JOB_ID = S.JOB_ID
LEFT JOIN MSDB.DBO.SYSJOBHISTORY AS H ON J.JOB_ID = H.JOB_ID
WHERE H.INSTANCE_ID = (
    SELECT MAX(INSTANCE_ID)
    FROM MSDB.DBO.SYSJOBHISTORY
    WHERE JOB_ID = J.JOB_ID
)
AND J.ENABLED = 1
ORDER BY MSDB.DBO.AGENT_DATETIME(RUN_DATE, RUN_TIME) DESC;

--------------------------- EXECUÇÃO DE STEPS DE JOBS --------------------------
SELECT
	J.NAME AS JOB_NAME,
	STEP_ID,
    STEP_NAME,
	CASE
        WHEN H.RUN_STATUS = 0 THEN 'FALHA'
        ELSE 'SUCESSO'
    END AS 'STATUS',
    -- RUN_DATE,
    --RUN_TIME,
    MSDB.DBO.AGENT_DATETIME(RUN_DATE, RUN_TIME) AS RUN_DATE_TIME,
    H.MESSAGE
FROM MSDB.DBO.SYSJOBS J
INNER JOIN MSDB.DBO.SYSJOBHISTORY H ON J.JOB_ID = H.JOB_ID
INNER JOIN SYS.SERVER_PRINCIPALS B ON J.OWNER_SID = B.SID
WHERE 
	STEP_ID > 0
    AND J.ENABLED = 1
    AND J.NAME in ('')
    AND MSDB.DBO.AGENT_DATETIME(RUN_DATE, RUN_TIME) >= CAST(GETDATE() as date )
ORDER BY RUN_DATE_TIME DESC, JOB_NAME;


--------------------------- LOG DE EXECUÇÃO DE QUERIES -------------------------
SELECT
    J.NAME AS 'JOBNAME',
    STEP_NAME,
    MSDB.DBO.AGENT_DATETIME(RUN_DATE, RUN_TIME) AS 'RUNDATETIME',
    H.MESSAGE
FROM MSDB.DBO.SYSJOBS J
INNER JOIN MSDB.DBO.SYSJOBHISTORY H ON J.JOB_ID = H.JOB_ID
INNER JOIN SYS.SERVER_PRINCIPALS B ON J.OWNER_SID = B.SID
WHERE
    J.ENABLED = 1
    AND J.NAME = ''
    AND MSDB.DBO.AGENT_DATETIME(RUN_DATE, RUN_TIME) > DATEADD(DAY, -1, GETDATE())
ORDER BY
    START_STEP_ID,
    MSDB.DBO.AGENT_DATETIME(RUN_DATE, RUN_TIME) DESC

--------------------------- LOG DE EXECUÇÃO DE QUERIES -------------------------
SELECT TOP 20
  START_TIME,
  STATUS,
  SQL_TEXT,
  SQL_COMMAND,
  DURATION,
  CPU,
  IDTIMESTAMP,
  LOGIN_NAME,
  HOST_NAME,
  DATABASE_NAME,
  PROGRAM_NAME
FROM [DBO].[LOGSESSIONS] 
ORDER BY 
  START_TIME DESC

-------------------------------- EXECUÇÃO NO MOMENTO ---------------------------
SELECT 
    SESSION_ID,
    WAIT_TYPE,
    START_TIME,
    STATUS,
    CPU_TIME,
    TOTAL_ELAPSED_TIME,
    READS,
    WRITES,
    LOGICAL_READS,
    [TEXT]
FROM SYS.DM_EXEC_REQUESTS
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(SQL_HANDLE)
--WHERE STATUS = 'RUNNING';

-------------------------------- EXECUÇÃO NO MOMENTO ---------------------------
SELECT
    r.session_id AS 'ID da Sessão',
    s.login_name AS 'Nome de Login',
    r.status AS 'Status',
    r.start_time AS 'Hora de Início',
    DATEDIFF(SECOND, r.start_time, GETDATE()) AS 'Tempo de Duração (segundos)',
    m.used_memory_kb AS 'Memoria em uso (kb)',
	r.command AS 'Comando',
	TEXT AS QUERY
FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(SQL_HANDLE)
INNER JOIN sys.dm_exec_query_memory_grants m ON m.session_id = s.session_id
WHERE CAST(r.start_time AS DATE) = CAST(GETDATE() AS DATE)
ORDER BY r.start_time DESC



--------------------------------------------------------------------------------
SELECT
	J.NAME AS JOB_NAME,
	STEP_ID,
    STEP_NAME,
	CASE
        WHEN H.RUN_STATUS = 0 THEN 'FALHA'
        ELSE 'SUCESSO'
    END AS 'STATUS',
    -- RUN_DATE,
    --RUN_TIME,
    MSDB.DBO.AGENT_DATETIME(RUN_DATE, RUN_TIME) AS RUN_DATE_TIME,
    H.MESSAGE
FROM MSDB.DBO.SYSJOBS J
INNER JOIN MSDB.DBO.SYSJOBHISTORY H ON J.JOB_ID = H.JOB_ID
INNER JOIN SYS.SERVER_PRINCIPALS B ON J.OWNER_SID = B.SID
WHERE 
	STEP_ID > 0
    AND J.ENABLED = 1
    AND J.NAME in ('')
    AND MSDB.DBO.AGENT_DATETIME(RUN_DATE, RUN_TIME) >= '2023-10-15 12:00:08.000'
ORDER BY RUN_DATE_TIME DESC, JOB_NAME;

