SELECT
    SESSION_ID,
    LOGIN_NAME,
    HOST_NAME ,
    PROGRAM_NAME,
    LOGIN_TIME,
    STATUS,
    CPU_TIME,
    MEMORY_USAGE,
    LAST_REQUEST_START_TIME,
    LAST_REQUEST_END_TIME,
    READS,
    WRITES
FROM SYS.DM_EXEC_SESSIONS
ORDER BY LOGIN_TIME  DESC


SELECT 
    R.SESSION_ID,
    R.BLOCKING_SESSION_ID,
    R.WAIT_TYPE,
    R.WAIT_TIME,
    R.WAIT_RESOURCE,
    R.STATUS,
    R.CPU_TIME,
    R.TOTAL_ELAPSED_TIME,
    R.READS,
    R.WRITES,
    R.LOGICAL_READS,
    S.ORIGINAL_LOGIN_NAME AS USER_NAME,
    T.TEXT AS [TEXT]
FROM SYS.DM_EXEC_REQUESTS R
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(R.SQL_HANDLE) AS T
JOIN SYS.DM_EXEC_SESSIONS S ON R.SESSION_ID = S.SESSION_ID
WHERE R.STATUS = 'RUNNING';


SELECT 
    SESSION_ID,
    BLOCKING_SESSION_ID,
    WAIT_TYPE,
    WAIT_TIME,
    WAIT_RESOURCE,
    STATUS,
    CPU_TIME,
    TOTAL_ELAPSED_TIME,
    READS,
    WRITES,
    LOGICAL_READS,
    [TEXT]
FROM SYS.DM_EXEC_REQUESTS
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(SQL_HANDLE)
WHERE STATUS = 'RUNNING';
