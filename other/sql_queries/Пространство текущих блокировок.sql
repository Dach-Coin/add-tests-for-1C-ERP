SELECT
 db_name(tl.resource_database_id) AS DB_Name,
 object_name(p.object_id) AS TableName,
 si.index_id AS IndexID,
 si.name AS IndexName,
 tl.resource_type AS ResourceType,
 tl.request_mode AS RequestMode,
 tl.request_type AS RequestType,
 tl.request_status AS RequestStatus,
 tl.request_session_id AS RequestSessionID,
 tl.resource_description AS ResourceDescription
FROM sys.dm_tran_locks AS tl 
 left join sys.partitions AS p
 ON p.hobt_id = tl.resource_associated_entity_id
 left join sys.indexes AS si
 ON p.object_id = si.object_id
 and p.index_id = si.index_id
WHERE 
	db_name(tl.resource_database_id) = 'MSK'
	AND ISNULL(object_name(p.object_id), 'Files') <> 'Files'
ORDER BY
 tl.request_session_id,
 si.index_id