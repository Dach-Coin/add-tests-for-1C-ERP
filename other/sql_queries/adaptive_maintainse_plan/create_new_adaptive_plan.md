# Как создать план обслуживания для адаптивного перестроения/дефрагментации индексов и адаптивного обновления статистик

1. Используем мощный функционал репозитария: https://github.com/microsoft/tigertoolbox/tree/master/AdaptiveIndexDefrag

    - Выполняем скрипт [usp_AdaptiveIndexDefrag](/other/sql_queries/adaptive_maintainse_plan/usp_AdaptiveIndexDefrag.sql), создаем в базах `msdb` и `master` таблицы и хранимые процедуры.
        (если целевая БД для обслуживания большая и высоконагруженная и планируется распараллелить обслуживание, если нет - достаточно только `msdb`)

    Результаты будет примерно такие:
    ```text
    Droping existing objects
    Preserving historic data
    tbl_AdaptiveIndexDefrag_log table created
    tbl_AdaptiveIndexDefrag_Analysis_log table created
    tbl_AdaptiveIndexDefrag_Exceptions table created
    tbl_AdaptiveIndexDefrag_Working table created
    tbl_AdaptiveIndexDefrag_Stats_Working table created
    tbl_AdaptiveIndexDefrag_Stats_log table created
    tbl_AdaptiveIndexDefrag_IxDisableStatus table created
    Copying old data...
    Done copying old data...
    Removed old tables...
    Procedure usp_AdaptiveIndexDefrag created
    Reporting views created
    Procedure usp_AdaptiveIndexDefrag_PurgeLogs created (Default purge is 90 days old)
    Procedure usp_AdaptiveIndexDefrag_CurrentExecStats created (Use this to monitor defrag loop progress)
    Procedure usp_AdaptiveIndexDefrag_Exceptions created (If the defrag should not be daily, use this to set on which days to disallow it. It can be on entire DBs, tables and/or indexes)
    All done!
    ```
    - После выполнения скрипта вносим некоторые исправления в хранимую процедуру `[dbo].[usp_AdaptiveIndexDefrag]`, используя скрипт [usp_upd_AdaptiveIndexDefrag](/other/sql_queries/adaptive_maintainse_plan/usp_upd_AdaptiveIndexDefrag.sql)

    - Проверяем работу скриптов для адаптивного обслуживания на копии целевой БД, в режиме отладки, выставив параметры:
        
        `@Exec_Print = 0`, `@printCmds = 1`, `@outputResults = 1`

        Скрипты: [adaptive_maintainse_plan](/other/sql_queries/adaptive_maintainse_plan)

        Также можно уменьшить или увеличит параметр `@rebuildThreshold` и посмотреть как изменится вывод
        (параметр регулирует порог, начиная с которого выполняется REBUILD, а не REORGANIZE)

        Результаты будет примерно такие:
        ```text
        ALTER INDEX [_InfoRg22907_3] ON [Acc_Interminerals1].[dbo].[_InfoRg22907] REORGANIZE WITH (LOB_COMPACTION = ON);
        -- No need to update statistic [_InfoRg22907_3] on table or view [_InfoRg22907] of DB [Acc_Interminerals1]...
        
        Not partition number specific...
        ALTER INDEX [_Reference12649_8] ON [Acc_Interminerals1].[dbo].[_Reference12649] DISABLE;
        ALTER INDEX [_Reference12649_8] ON [Acc_Interminerals1].[dbo].[_Reference12649] REBUILD WITH (DATA_COMPRESSION = NONE, FILLFACTOR = 100, SORT_IN_TEMPDB = ON);
        
        Not partition number specific...
        UPDATE STATISTICS [Acc_Interminerals1].[dbo].[_ReferenceChngR1020] ([_ReferenceChngR1020_2]); 
        ALTER INDEX [_ReferenceChngR1020_2] ON [Acc_Interminerals1].[dbo].[_ReferenceChngR1020] REBUILD WITH (DATA_COMPRESSION = NONE, FILLFACTOR = 100, SORT_IN_TEMPDB = ON);
        ```

2. Если скрипты успешно заработали в режиме отладки, тогда:
    - создаем план обслуживания и в нем подчиненный план, например `Адаптивная дефрагментация/перестроение и обновление статистик`;
    - скрипты внутри плана запускаем параллельно. Разделяем их по количеству страниц внутри таблицы: `@maxPageCount` - этот параметр следует подобрать экспериментально;
    - для экспериментального подбора `@maxPageCount` следует сначала позапускать обслуживание в 1 поток, проанализировать логи и понять, на каких таблицах чаще всего устаревает статистика и фрагментируются индексы - исходя из этих данных уже разделять обслуживание на большие и маленькие таблицы;
    - данный план для баз среднего и средне-крупного размера и средне-высокой транзакционной нагруженности достаточно запускать 2-3 раза в неделю. Время выполнения такого плана будет в несколько раз меньше, чем время выполнения обычных "задач-кубиков" mssql;
    - если база небольшая или не высоконагруженная, то достаточно и 1 скрипта без разделения по параметру `@maxPageCount`;
    - создаем еще один подчиненный план, например `Адаптивное обновление статистики`. Для него используем скрипт `Адаптивный апдейт статистик`;
    - если базы относительно небольшие, можно настроить один сквозной план, вызывая в нем скрипт, в котором адаптивное обслуживание будет запущено в цикле, для каждой пользовательской базы, см. скрипты:
    `Адаптивный апдейт статистик по всем базам`, `Адаптивный дефраг индексов и апдейт статистик по всем базам`;
    - если версия MS SQL поддерживает онлайн-перестроение индексов, то необходимо установить параметр `@onlineRebuild` в значение 1 (см. https://docs.microsoft.com/ru-ru/sql/sql-server/editions-and-components-of-sql-server-2017?view=sql-server-ver15)

3. Пример плана обслуживания:
    - каждый день в начале регламентного окна запускаем адаптивное обновление статистик, полный бэкап, удаление устаревших бэкапов, очистку журналов обслуживания агента MS SQL;
    - каждый день, каждые полчаса (исключая время регламентного окна) запускаем бэкап и шринк лог-файлов. Ежедневный полный бэкап и частые бэкапы логов транзакций обеспечивают нам возможность восстановления базы на любой момент времени с точностью 30 минут, при этом копии логов транзакций не разрастаются (бэкапируется только "дельта"), можно сохранять лог и чаще - операция быстрая и не нагружает сервер;
    - любое обслуживание целесообразно запускать до операции создания полного бэкапа, чтобы при необходимости восстановления не пришлось ожидать пересчета большого количества служебных транзакций;
    - для баз данных средне-высокой транзакционной нагруженности 2-3 раза в неделю запускаем адаптивный дефраг/ребилд индексов (для более высоко-нагруженных баз данных можно запускать чаще);

    Примеры в скриншотах:
     - пример 1:
        ![](/other/img/Maintenance1.png)
        ![](/other/img/Maintenance2.png)
        ![](/other/img/Maintenance3.png)

    - пример 2: ![](/other/img/Maintenance4.png)