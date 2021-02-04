
SELECT TOP 1000 [index_handle]
      ,[database_id]
      ,[object_id]
      ,[equality_columns]
      ,[inequality_columns]
      ,[included_columns]
      ,[statement]
  FROM [EDB_consolidation].[sys].[dm_db_missing_index_details]
  where [statement] = '[EDB_consolidation].[dbo].[EdbTranzactions]'



Интересная методика представлена в Учебном курсе Microsoft “SQL Server 2005 Реализация и обслуживание”.
Решение о эффективности индекса предлагается принять из расчета некоторого значения по формуле user_seeks * avg_total_user_cost * (avg_user_impact * 0.01). Исходные данные для расчета берутся из представлений sys.dm_db_missing_index*.
Значение выше 5000 в промышленных системах означает, что следует рассмотреть возможность создания этих индексов.
Если же значение превышает 10000, это обычно означает, что индекс может обеспечить значительное повышение производительности для операций чтения.
Немного творчества и получаем вот такой скрипт:


SELECT [Преимущество индекса] = user_seeks * avg_total_user_cost * (avg_user_impact * 0.01),

      [Transact SQL код для создания индекса] = 'CREATE INDEX [IX_' + 'EDB_consolidation' + '_' + 

      CAST(mid.index_handle AS nvarchar) + '] ON ' + 

      mid.statement + ' (' + ISNULL(mid.equality_columns,'') + 

      (CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ', ' 

ELSE '' END) + 

      (CASE WHEN mid.inequality_columns IS NOT NULL THEN + mid.inequality_columns ELSE '' END) + ')' + 

      (CASE WHEN mid.included_columns IS NOT NULL THEN ' INCLUDE (' + mid.included_columns + ')' 

ELSE '' END) +      ';',

	  [База данных] = DB_NAME(mid.database_id),

      [Число компиляций] = migs.unique_compiles,

      [Количество операций поиска] = migs.user_seeks,

      [Количество операций просмотра] = migs.user_scans,

      [Средняя стоимость ] = CAST(migs.avg_total_user_cost AS int),

      [Средний процент выигрыша] = CAST(migs.avg_user_impact AS int)

FROM  sys.dm_db_missing_index_groups mig

JOIN  sys.dm_db_missing_index_group_stats migs 

ON    migs.group_handle = mig.index_group_handle

JOIN  sys.dm_db_missing_index_details mid 

ON    mig.index_handle = mid.index_handle

ORDER BY [Преимущество индекса] DESC