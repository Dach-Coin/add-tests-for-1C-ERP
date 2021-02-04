DECLARE @Table TABLE(SPID INT, 
					 Status VARCHAR(MAX),
					 LOGIN VARCHAR(MAX),
					 HostName VARCHAR(MAX),
					 BlkBy VARCHAR(MAX),
					 DBName VARCHAR(MAX),
					 Command VARCHAR(MAX),
					 CPUTime INT,
					 DiskIO INT,
					 LastBatch VARCHAR(MAX),
					 ProgramName VARCHAR(MAX),
					 SPID_1 INT,
					 REQUESTID INT)

INSERT INTO @Table EXEC sp_who2

SELECT DISTINCT BlkBy FROM @Table

SELECT * FROM @Table
WHERE DBName = 'MSK'
AND Status <> 'sleeping'
ORDER BY CPUTime Desc  