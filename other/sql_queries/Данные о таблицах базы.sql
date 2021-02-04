DECLARE @tablename VARCHAR (128)
DECLARE @id int
DECLARE @pages int
DECLARE @rows int
DECLARE @reserved dec(15)
DECLARE @data dec(15)
DECLARE @indexp dec(15)
DECLARE @unused dec(15)


CREATE TABLE #tabprop (
  name CHAR (100),
  rows int,
  reserved dec(15),
  data dec(15),
  index_size dec(15),
  unused dec(15))

-- Declare cursor
DECLARE tables CURSOR FOR
  SELECT TABLE_NAME
  FROM INFORMATION_SCHEMA.TABLES
  WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME<>'dtproperties'

OPEN tables

-- Loop through all the tables in the database
FETCH NEXT
  FROM tables
  INTO @tablename

WHILE @@FETCH_STATUS = 0
BEGIN
   SELECT @id = id FROM sysobjects WHERE id =object_id(@tablename)
   SELECT @reserved=SUM(reserved) FROM sysindexes WHERE indid in (0, 1, 255) and id = @id
   SELECT @pages = SUM(dpages) FROM sysindexes WHERE indid < 2 and id = @id
   SELECT @pages = @pages + isnull(SUM(used), 0) FROM sysindexes WHERE indid = 255 and id = @id
   SET @data = @pages
   SET @indexp = (select SUM(used) FROM sysindexes WHERE indid in (0, 1, 255) and id = @id) - @data
   SET @unused = @reserved - (SELECT SUM(used) FROM sysindexes WHERE indid in (0, 1, 255) and id = @id)
   SELECT @rows=rows FROM sysindexes WHERE indid < 2 and id = @id

  INSERT INTO #tabprop
   SELECT name = RTRIM(CONVERT(char(100),object_name(@id)))
       , rows = @rows
       , reserved = @reserved * d.low / 1024.
       , data = @data * d.low / 1024.
       , index_size = @indexp * d.low / 1024.
       , unused = @unused * d.low / 1024.
   FROM master.dbo.spt_values d WHERE d.number = 1 and d.type = 'E'

/*
-- Do the showcontig of all indexes of the table
  INSERT INTO #fraglist
  EXEC ('DBCC SHOWCONTIG (''' + @tablename + ''')
     WITH FAST, TABLERESULTS, ALL_INDEXES, NO_INFOMSGS')
*/

  FETCH NEXT
     FROM tables
     INTO @tablename
END

CLOSE tables
DEALLOCATE tables

select name as Имя
   , rows as КоличествоСтрок
   , reserved as Всего
   , data as Данные
   , index_size as Индескы
   , unused as Свободно
from #tabprop
order by reserved desc

drop TABLE #tabprop