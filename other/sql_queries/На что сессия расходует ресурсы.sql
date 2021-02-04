DECLARE @sql_handle varbinary(64)
DECLARE @plan_handle varbinary(64)
DECLARE @sid INT
Declare @statement_start_offset int, @statement_end_offset INT, @session_id SMALLINT

-- для инфы по конкретному юзеру - указываем номер сессии
SELECT @sid=182

-- получаем переменные состояния для дальнейшей обработки
IF @sid IS NOT NULL
SELECT @sql_handle=der.sql_handle, @plan_handle=der.plan_handle, @statement_start_offset=der.statement_start_offset, @statement_end_offset=der.statement_end_offset, @session_id = der.session_id
FROM sys.dm_exec_requests der WHERE der.session_id=@sid

--печатаем текст выполняемого запроса
DECLARE @txt VARCHAR(max)
IF @sql_handle IS NOT NULL
SELECT @txt=[text] FROM sys.dm_exec_sql_text(@sql_handle)
PRINT @txt
-- выводим план выполняемого батча/процы
IF @plan_handle IS NOT NULL
select * from sys.dm_exec_query_plan(@plan_handle)
-- и план выполняемого запроса в рамках батча/процы
IF @plan_handle IS NOT NULL
SELECT dbid, objectid, number, encrypted, CAST(query_plan AS XML) AS planxml
from sys.dm_exec_text_query_plan(@plan_handle, @statement_start_offset, @statement_end_offset)