SET NOCOUNT ON 
DECLARE @filename VARCHAR(500) 
SELECT @filename = SUBSTRING(path, 0,LEN(path) - CHARINDEX('\',REVERSE(path)) + 1)+ '\Log.trc'
FROM sys.traces
WHERE is_default = 1 ;

SELECT TOP (1000)
  te.Name AS EventName
  ,StartTime
  ,LoginName
  ,ApplicationName
  ,HostName
  ,DatabaseName
  ,IntegerData/128 [Size MB]
  ,CAST(Duration/1000000. AS DECIMAL(20,2)) AS [Duration sec]
  ,EndTime
  ,SPID
  ,SessionLoginName
FROM fn_trace_gettable(@fileName, DEFAULT) gt 
  INNER JOIN sys.trace_events te ON EventClass = te.trace_event_id 
WHERE DatabaseName = 'tempdb'
  AND EventClass IN(92, 93)-- Data/Log File Auto Grow
ORDER BY StartTime DESC