CREATE EVENT SESSION [Query_Compilation_Execution] ON SERVER 
ADD EVENT sqlserver.blocked_process_report(
    ACTION(sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([database_name]=N'ERP_demo' AND [duration]>=(5000000))),
ADD EVENT sqlserver.query_post_execution_showplan(SET collect_database_name=(1)
    ACTION(sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([database_name],N'ERP_demo') AND [package0].[greater_than_equal_uint64]([duration],(1500000)))),
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'ERP_demo') AND [package0].[greater_than_equal_uint64]([duration],(2000000)))),
ADD EVENT sqlserver.sql_batch_completed(SET collect_batch_text=(1)
    ACTION(sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'ERP_demo' AND [duration]>=(1000000)))
ADD TARGET package0.event_file(SET filename=N'D:\SQL\extended_events\Query_Compilation_Execution.xel',max_file_size=(10240))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=3 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO