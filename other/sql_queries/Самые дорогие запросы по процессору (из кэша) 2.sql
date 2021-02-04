SELECT 
	topq.statement_text,
	topq.creation_time,
	topq.last_execution_time,
	topq.execution_count,
	topq.avg_worker_time,
	topq.avg_physical_reads,
	topq.avg_logical_reads,
	topq.max_dop,
	topq.plan_handle,
	qp.query_plan
FROM 
(
	SELECT TOP 20
		MIN(qstats.statement_text) AS statement_text,
		MIN(qstats.plan_handle) AS plan_handle,
		MIN(qstats.creation_time) AS creation_time,
		MAX(qstats.last_execution_time) AS last_execution_time,
		SUM(qstats.execution_count) AS execution_count,
		SUM(qstats.total_worker_time) / SUM(qstats.execution_count) AS avg_worker_time,
		SUM(qstats.total_physical_reads) / SUM(qstats.execution_count) AS avg_physical_reads,
		SUM(qstats.total_logical_reads) / SUM(qstats.execution_count) AS avg_logical_reads,
		MAX(qstats.max_dop) AS max_dop
	FROM
		(SELECT
			qs.query_hash,
			qs.plan_handle,
			qs.creation_time,
			qs.last_execution_time,
			qs.execution_count,
			qs.total_worker_time,
			qs.total_physical_reads,
			qs.total_logical_reads,
			qs.max_dop,
			SUBSTRING(st.text, (qs.statement_start_offset/2)+1,   
					((CASE qs.statement_end_offset  
					  WHEN -1 THEN DATALENGTH(st.text)  
					 ELSE qs.statement_end_offset  
					 END - qs.statement_start_offset)/2) + 1) AS statement_text
		FROM sys.dm_exec_query_stats AS qs
		CROSS APPLY sys.dm_exec_sql_text(qs.plan_handle) AS st

		WHERE st.dbid = DB_ID('database_1c') ) AS qstats

	GROUP BY qstats.query_hash
	HAVING MIN(qstats.statement_text) LIKE 'SELECT%'
	ORDER BY avg_worker_time DESC

) topq

CROSS APPLY sys.dm_exec_query_plan(topq.plan_handle) qp