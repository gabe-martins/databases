SELECT  
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_SCHEMA = ''
    -- AND TABLE_NAME = ''

SELECT
    j.name AS JobName,
    -- h.step_name AS StepName,
    h.run_date AS RunDate,
    h.run_time AS RunTime,
    round((h.run_duration/60)/60, 2) AS [RunDuration (seconds)]
FROM
    msdb.dbo.sysjobhistory AS h
    INNER JOIN msdb.dbo.sysjobs AS j ON h.job_id = j.job_id
WHERE
    h.step_id = 0 
	and h.run_date = '20230623'
	and j.name <> 'Sessions'
ORDER BY
	h.run_duration desc
    -- h.run_date DESC, h.run_time DESC;
