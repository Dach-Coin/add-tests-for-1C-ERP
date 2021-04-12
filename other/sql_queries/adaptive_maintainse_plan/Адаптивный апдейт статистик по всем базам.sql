USE [msdb]

DECLARE @limitMinutes int = 480 /* 8 hours */ 
SET DATEFIRST 1 /* (Mondey) */
IF DatePart(weekday, GetDate()) IN (5, 6) SET @limitMinutes = 1440; /* 24 hours */

-- вызов адаптивного обновления статистик в цикле по списку пользовательских баз:

IF OBJECT_ID (N'tempdb..##tt000', N'U') IS NOT NULL DROP TABLE ##tt000;

SELECT 
	name AS DBname,
	ROW_NUMBER() OVER(order by name desc) AS numrow
INTO ##tt000
FROM sys.databases
WHERE database_id > 4;

DECLARE @nbr_statements INT = (SELECT COUNT(*) FROM ##tt000), @i INT = 1;

WHILE   @i <= @nbr_statements
BEGIN
    
	DECLARE @DBname NVARCHAR(4000) = (SELECT DBname FROM ##tt000 WHERE numrow = @i);
    
	PRINT @DBname; 
	
	BEGIN

		EXEC dbo.usp_AdaptiveIndexDefrag  
		   @Exec_Print = 1 /* 1 = execute commands; 0 = print commands only */
		 , @printCmds = 0 /* 1 = print commands; 0 = do not print commands */
		 , @outputResults = 0 /* 1 = output fragmentation information; 0 = do not output */
		 , @debugMode = 0 /* display some useful comments to help determine if/where issues occur; 1 = display debug comments; 0 = do not display debug comments*/
		 , @timeLimit = @limitMinutes
		 , @dbScope = @DBname
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
		 , @disableNCIX = 1  /* 0 = does NOT disable non-clustered indexes prior to a rebuild; 1 = disables non-clustered indexes prior to a rebuild, if the database is not being replicated (space saving feature) */ 
		 , @offlinelocktimeout = -1 /* -1 = (default) indicates no time-out period; Any other positive integer sets the number of milliseconds that will pass before Microsoft SQL Server returns a locking error */
		 , @maxDopRestriction = 4;

	END;

    SET @i +=1;

END;
 
drop table ##tt000