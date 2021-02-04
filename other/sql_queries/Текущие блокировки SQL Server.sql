SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @dbid AS smallint;
use EDB_consolidation;
SET @dbid=DB_ID();

/*кто кого*/
SELECT DB_NAME(pr1.dbid) AS 'DB'
      ,pr1.spid AS 'ID жертвы'
      ,RTRIM(pr1.loginame) AS 'Login жертвы'
      ,pr2.spid AS 'ID виновника'
      ,RTRIM(pr2.loginame) AS 'Login виновника'
      ,pr1.program_name AS 'программа жертвы'
      ,pr2.program_name AS 'программа виновника'
      ,txt.[text] AS 'Запрос виновника'
FROM   MASTER.dbo.sysprocesses pr1(NOLOCK)
       JOIN MASTER.dbo.sysprocesses pr2(NOLOCK)
            ON  (pr2.spid = pr1.blocked)
       OUTER APPLY sys.[dm_exec_sql_text](pr2.[sql_handle]) AS txt
WHERE  pr1.blocked <> 0