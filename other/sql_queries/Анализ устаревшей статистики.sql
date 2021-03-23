USE [db_name]

select
    o.name AS [TableName],
    a.name AS [StatName],
    a.rowmodctr AS [RowsChanged],
	a.rowcnt,
	ROUND(SQRT(1000 * a.rowcnt), 0) AS threshold,
	CASE
		WHEN SQRT(1000 * a.rowcnt) < a.rowmodctr AND a.rowcnt > 0 THEN 1
		ELSE 0
	END AS [NeedUpdate],
    STATS_DATE(s.object_id, s.stats_id) AS [LastUpdate],
    o.is_ms_shipped,
    s.is_temporary,
    p.*,
	'UPDATE STATISTICS [dbo].[' + o.name + '] ([' + a.name + ']) WITH FULLSCAN'
from sys.sysindexes a
    inner join sys.objects o
    on a.id = o.object_id
        and o.type = 'U'
        and a.id > 100
        and a.indid > 0
    left join sys.stats s
    on a.name = s.name
    left join (
SELECT
        p.[object_id]
, p.index_id
, total_pages = SUM(a.total_pages)
    FROM sys.partitions p WITH(NOLOCK)
        JOIN sys.allocation_units a WITH(NOLOCK) ON p.[partition_id] = a.container_id
    GROUP BY 
p.[object_id]
, p.index_id
) p ON o.[object_id] = p.[object_id] AND p.index_id = s.stats_id
WHERE
	/* Отбор по статистике для обновления (без учета количества строк в таблице по алгоритму,
	как с флагом трассировки 2371 */
	CASE
		WHEN SQRT(1000 * a.rowcnt) < a.rowmodctr AND a.rowcnt > 0 THEN 1
		ELSE 0
	END = 1
order by
    a.rowmodctr desc,
    STATS_DATE(s.object_id, s.stats_id) ASC