/* Используем хранимые процедуры, заранее созданные скриптом: https://github.com/microsoft/tigertoolbox/blob/master/AdaptiveIndexDefrag/usp_AdaptiveIndexDefrag.sql
   Хранимые процедуры и таблицы логов должны быть заранее созданы в базе [master]
   
   Адаптивный дефраг индексов и апдейт статистик у больших таблиц */

USE [master]

DECLARE @limitMinutes int = 480 /* 8 hours */

SET DATEFIRST 1 /* (Mondey) */
IF DatePart(weekday, GetDate()) IN (5, 6) SET @limitMinutes = 1440 /* 24 hours */ 
 
EXEC dbo.usp_AdaptiveIndexDefrag  
   @Exec_Print = 1 /* 1 = execute commands; 0 = print commands only */
 , @printCmds = 0 /* 1 = print commands; 0 = do not print commands */
 , @outputResults = 0 /* 1 = output fragmentation information; 0 = do not output */
 , @debugMode = 0 /* display some useful comments to help determine if/where issues occur; 1 = display debug comments; 0 = do not display debug comments*/
 , @timeLimit = @limitMinutes
 , @dbScope = 'ERP_demo' 
 , @forceRescan = 1   /* Whether to force a rescan of indexes into the tbl_AdaptiveIndexDefrag_Working table or not; 1 = force, 0 = use existing scan when available, used to continue where previous run left off */
 , @defragDelay = '00:00:05'
 , @minFragmentation = 5
 , @rebuildThreshold = 30
 , @minPageCount = 100000
 --, @maxPageCount = 
 , @sortInTempDB = 1
 , @updateStats = 1  /* 1 = updates stats when reorganizing; 0 = does not update stats when reorganizing */
 , @updateStatsWhere = 0 /* 1 = updates only index related stats; 0 = updates all stats in table */
 , @statsSample = 'FULLSCAN' /* Valid options are: NULL, <percentage>, FULLSCAN, and RESAMPLE */
 , @disableNCIX = 1  /* 0 = does NOT disable non-clustered indexes prior to a rebuild; 1 = disables non-clustered indexes prior to a rebuild, if the database is not being replicated (space saving feature) */ 
 , @offlinelocktimeout = -1; /* -1 = (default) indicates no time-out period; Any other positive integer sets the number of milliseconds that will pass before Microsoft SQL Server returns a locking error */