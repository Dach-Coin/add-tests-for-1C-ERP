-- Create required table structure only.
-- Note: this SQL must be the same as in the Database loop given in the following step.
SELECT TOP 1
        DatabaseName = DB_NAME()
        ,TableName = OBJECT_NAME(s.[object_id])
        ,IndexName = i.name
        ,user_updates    
        ,system_updates    
        -- Useful fields below:
        --, *
INTO #TempUnusedIndexes
FROM   sys.dm_db_index_usage_stats s 
INNER JOIN sys.indexes i ON  s.[object_id] = i.[object_id] 
    AND s.index_id = i.index_id 
WHERE  s.database_id = DB_ID()
    AND OBJECTPROPERTY(s.[object_id], 'IsMsShipped') = 0
    AND    user_seeks = 0
    AND user_scans = 0 
    AND user_lookups = 0
    AND s.[object_id] = -999  -- Dummy value to get table structure.
;

-- Loop around all the databases on the server.
EXEC sp_MSForEachDB    'USE [?]; 
-- Table already exists.
INSERT INTO #TempUnusedIndexes 
SELECT TOP 10    
        DatabaseName = DB_NAME()
        ,TableName = OBJECT_NAME(s.[object_id])
        ,IndexName = i.name
        ,user_updates    
        ,system_updates    
FROM   sys.dm_db_index_usage_stats s 
INNER JOIN sys.indexes i ON  s.[object_id] = i.[object_id] 
    AND s.index_id = i.index_id 
WHERE  s.database_id = DB_ID()
    AND OBJECTPROPERTY(s.[object_id], ''IsMsShipped'') = 0
    AND    user_seeks = 0
    AND user_scans = 0 
    AND user_lookups = 0
    AND i.name IS NOT NULL    -- Ignore HEAP indexes.
ORDER BY user_updates DESC
;
'

-- Select records.
SELECT TOP 10 * FROM #TempUnusedIndexes ORDER BY [user_updates] DESC
-- Tidy up.
DROP TABLE #TempUnusedIndexes