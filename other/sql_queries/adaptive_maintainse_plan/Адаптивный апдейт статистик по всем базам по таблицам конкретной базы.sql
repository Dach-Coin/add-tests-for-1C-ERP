USE [msdb];

IF OBJECT_ID (N'tempdb..##tt000', N'U') IS NOT NULL DROP TABLE ##tt000;

SELECT 
	name AS DBname,
	ROW_NUMBER() OVER(order by name desc) AS numrow
INTO ##tt000
FROM sys.databases
WHERE database_id > 4;

DECLARE @nbr_statements INT = (SELECT COUNT(*) FROM ##tt000), @i INT = 1;

WHILE @i <= @nbr_statements

-- цикл по всем базам

BEGIN
    
	DECLARE @DBname NVARCHAR(4000) = (SELECT DBname FROM ##tt000 WHERE numrow = @i);
    
	PRINT ' '
	PRINT 'Next base = '
	PRINT @DBname;

	BEGIN
		-- работа с текущей выбранной базой

		IF OBJECT_ID (N'tempdb..##tt111', N'U') IS NOT NULL DROP TABLE ##tt111;

		-- получаем все пользовательские таблицы базы, отсортировав их в порядке убывания размера данных

		DECLARE @change_context nvarchar(100) = QUOTENAME(@DBname) + N'.sys.sp_executesql'

		DECLARE @sql_text nvarchar(max) = 
		'SELECT
		  ROW_NUMBER() OVER(order by (SUM(a.total_pages) * 8) desc) AS numrow,
		  t.Name													AS TableName,
		  s.Name													AS SchemaName,
		  p.Rows													AS RowCounts,  
		  SUM(a.total_pages) * 8									AS TotalSpaceKB,
		  SUM(a.used_pages) * 8										AS UsedSpaceKB,
		  (SUM(a.total_pages) - SUM(a.used_pages)) * 8				AS UnusedSpaceKB
		INTO ##tt111
		FROM
		  sys.tables t
		  INNER JOIN sys.indexes i ON t.object_id = i.object_id
		  INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
		  INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
		  INNER JOIN sys.objects obj ON t.name = obj.name AND obj.type in (N''U'')
		  LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id
		GROUP BY
		  t.Name, s.Name, p.Rows
		ORDER BY
		  TotalSpaceKB DESC;'

		EXEC @change_context @sql_text

		DECLARE @nbr_statementsTab INT = (SELECT COUNT(*) FROM ##tt111), @j INT = 1;

		WHILE @j <= @nbr_statementsTab

		-- цикл по таблицам текущей базы (в первую очередь обрабатываются наиболее "тяжелые" таблицы)

		BEGIN
    
			DECLARE @TableName NVARCHAR(4000) = (SELECT TableName FROM ##tt111 WHERE numrow = @j);
			DECLARE @SchemaName NVARCHAR(4000) = (SELECT SchemaName FROM ##tt111 WHERE numrow = @j);
			DECLARE @FullTableName NVARCHAR(4000) = @SchemaName + '.' + @TableName;
	
			PRINT @FullTableName

			USE [msdb]

			BEGIN

				-- полезная нагрузка: вызов процедуры адаптивного обслуживания

				EXEC dbo.usp_AdaptiveIndexDefrag  
				   @Exec_Print = 1 /* 1 = execute commands; 0 = print commands only */
				 , @printCmds = 0 /* 1 = print commands; 0 = do not print commands */
				 , @outputResults = 0 /* 1 = output fragmentation information; 0 = do not output */
				 , @debugMode = 0 /* display some useful comments to help determine if/where issues occur; 1 = display debug comments; 0 = do not display debug comments*/
				 , @timeLimit = 480
				 , @dbScope = @DBname
				 , @tblName = @FullTableName
				 , @defragOrderColumn = 'page_count' /* Valid options are: range_scan_count, fragmentation, page_count */
				 , @forceRescan = 1   /* Whether to force a rescan of indexes into the tbl_AdaptiveIndexDefrag_Working table or not; 1 = force, 0 = use existing scan when available, used to continue where previous run left off */
				 , @defragDelay = '00:00:05'
				 , @minFragmentation = 100
				 , @rebuildThreshold = 100
				 , @minPageCount = 8
				 , @sortInTempDB = 1
				 , @updateStats = 1  /* 1 = updates stats when reorganizing; 0 = does not update stats when reorganizing */
				 , @updateStatsWhere = 0 /* 1 = updates only index related stats; 0 = updates all stats in table */
				 , @statsSample = 'FULLSCAN' /* Valid options are: NULL, <percentage>, FULLSCAN, and RESAMPLE */
				 , @disableNCIX = 0  /* 0 = does NOT disable non-clustered indexes prior to a rebuild; 1 = disables non-clustered indexes prior to a rebuild, if the database is not being replicated (space saving feature) */ 
				 , @offlinelocktimeout = -1 /* -1 = (default) indicates no time-out period; Any other positive integer sets the number of milliseconds that will pass before Microsoft SQL Server returns a locking error */
				 , @maxDopRestriction = 4;

			END;
	
			SET @j +=1;

		END;

		drop table ##tt111

	END;

	SET @i +=1; 

END;

drop table ##tt000