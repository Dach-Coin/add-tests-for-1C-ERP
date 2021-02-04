# Краткая инструкция по настройке "дежурного" мониторинга на серверах 1С (win) и СУБД (MS SQL)

1. Настраиваем счетчики perfmon на ВСЕХ серверах.

    - \Memory\% Committed Bytes In Use
    - \Memory\Available MBytes
    - \Processor(_Total)\% Processor Time
    - \Network Interface(*)\Bytes Total/sec
    - \System\Processor Queue Length
    - \PhysicalDisk(0 D:)\Avg. Disk Queue Length
    - \PhysicalDisk(1 C:)\Avg. Disk Queue Length
    - \Память\% использования выделенной памяти
    - \Память\Доступно МБ
    - \Процессор(_Total)\% загруженности процессора
    - \Сетевой интерфейс(*)\Всего байт/с
    - \Система\Длина очереди процессора
    - \Физический диск(0 D:)\Средняя длина очереди диска
    - \Физический диск(1 C:)\Средняя длина очереди диска

2. Настраиваем дополнительные счетчики perfmon на серверах БД:

    - \SQLServer:Latches\Total Latch Wait Time (ms)
    - \SQLServer:Locks(_Total)\Lock Timeouts/sec
    - \SQLServer:Databases(tempdb)\Active Transactions
    - \SQLServer:Databases(_Total)\Active Transactions
    - \SQLServer:Buffer Manager\Page life expectancy
    - \SQLServer:Buffer Manager\Buffer cache hit ratio
    - \SQLServer:Buffer Manager\Page reads/sec
    - \SQLServer:Buffer Manager\Page writes/sec
    - \SQLServer:Buffer Manager\Lazy writes/sec
    - \SQLServer:Plan Cache(_Total)\Cache Hit Ratio
    - \SQLServer:Latches\Total Latch Wait Time (ms)
    - \SQLServer:Locks(_Total)\Lock Timeouts/sec
    - \SQLServer:Databases(tempdb)\Active Transactions
    - \SQLServer:Databases(_Total)\Active Transactions
    - \SQLServer:Buffer Manager\Page life expectancy
    - \SQLServer:Buffer Manager\Buffer cache hit ratio
    - \SQLServer:Buffer Manager\Page reads/sec
    - \SQLServer:Buffer Manager\Page writes/sec
    - \SQLServer:Buffer Manager\Lazy writes/sec
    - \SQLServer:Plan Cache(_Total)\Cache Hit Ratio

3. Общие параметры для всех счетчиков:
    - Интервал выборки - 5;
    - Формат журнала: двоичный
    - файлы счетчиков весят немного, для хранения можно оставить каталог по умолчанию.

4. Настраиваем "дежурный" технологический журнал (собирающий самые необходимые события, с фильтрами по целевой ИБ и длительности)

    <details>
        <summary>logcfg.xml</summary>

            <?xml version="1.0"?>
            <config xmlns="http://v8.1c.ru/v8/tech-log">
                <log history="72" location="D:\1С_logs">
                    <property name="all"/>
                    <event>
                        <eq property="name" value="ADMIN"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <eq property="name" value="PROC"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <eq property="name" value="LEAKS"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <!-- <event>
                        <eq property="name" value="CONN"/>
                    </event> -->
                    <event>
                        <eq property="name" value="MEM"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <eq property="name" value="ATTN"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <eq property="name" value="QERR"/>
                        <gt property="duration" value="100000"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <eq property="Name" value="TDEADLOCK"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <eq property="name" value="TTIMEOUT"/>
                        <gt property="duration" value="100000"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <eq property="name" value="SDBL"/>
                        <gt property="duration" value="100000"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <eq property="name" value="SDBL"/>
                        <eq property="func" value="setrollbackonly"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <eq property="name" value="DBMSSQL"/>
                        <gt property="duration" value="100000"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <eq property="name" value="CALL"/>
                        <gt property="memorypeak" value="100000000"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <eq property="name" value="TLOCK"/>
                        <gt property="duration" value="100000"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <eq property="Name" value="EXCP"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <eq property="Name" value="EXCPCNTX"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <!-- <event>
                        <gt property="lkpto" value="0"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event>
                    <event>
                        <gt property="lkato" value="0"/>
                        <like property="p:processName" value="ERP_demo"/>
                    </event> -->
                </log>
                <dump create="true" type="3" location="D:\1С_logs\Dumps" externaldump="1" prntscrn="false"/>
                <dbmslocks/>
            </config>

    </details>

    Все события, настроенные в данном примере - достаточны для первичного разбора проблем и не привносят существенных задержек в работу сервера 1С.
    События `lkpto` и `lkato` могут привносить ощутимые задержки в работу сервера 1С, их необходимо включать только при необходимости и на короткое время.
    Событие CONN увеличивает размер файлов логов ТЖ, его следует включать при подозрениях на сетевые проблемы.

    - Имя целевой ИБ, каталоги хранения логов и дампов указываем свои
    - Отличное описание событий, фиксируемых в ТЖ: https://infostart.ru/1c/articles/1195695/

5. Настраиваем на серверах СУБД сеансы отслеживания расширенных событий (extended events)

    Скрипт для создания (указаны минимально-достаточные для оперативных расследований события):

    ```sql
    CREATE EVENT SESSION [Query_Compilation_Execution] ON SERVER 
    ADD EVENT sqlserver.blocked_process_report(
    ACTION(sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([database_name]=N'ERP_demo' AND [duration]>=(5000000))),
    ADD EVENT sqlserver.query_post_execution_showplan(SET collect_database_name=(1)
    ACTION(sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([database_name],N'ERP_demo') AND [package0].[greater_than_equal_uint64]([duration],(1500000)))),
    ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[equal_i_sql_unicode_string]([sqlserver].[database_name],N'ERP_demo') AND [package0].[greater_than_equal_uint64]([duration],(2000000)))),
    ADD EVENT sqlserver.sql_batch_completed(SET collect_batch_text=(1)
    ACTION(sqlserver.database_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'ERP_demo' AND [duration]>=(1000000)))
    ADD TARGET package0.event_file(SET filename=N'D:\SQL\extended_events\Query_Compilation_Execution.xel',max_file_size=(10240))
    WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=3 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
    GO
    ```

    `ERP_demo` меняем на имя целевой БД.
    `D:\SQL\extended_events` меняем на свой путь.
    `duration` для событий настраиваем по своему усмотрению, исходя из загруженности целевой БД.

    Что такое расширенные события:
    
    https://docs.microsoft.com/ru-ru/sql/relational-databases/extended-events/quick-start-extended-events-in-sql-server?view=sql-server-ver15

    https://infostart.ru/1c/articles/1056294/

6. Если версия MS SQL - 2016 и старше, можно настроить хранилище запросов:

    https://infostart.ru/1c/articles/1054413/
    
    https://docs.microsoft.com/ru-ru/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store?view=sql-server-ver15

7. Инспектируем сервера 1С и СУБД на предмет "детских" ошибок:
    - Каталог кластера `srvinfo` должен находиться на быстром диске (по возможности SSD), с достаточным количеством места;
    - Должны быть настроены квоты на свободное место на дисках с рассылкой предупреждений администраторам (или аналогичный мониторинг скриптами shell)
    - Для рабочих баз должна быть настроена полная модель восстановления + создание резервных копий https://infostart.ru/1c/articles/173494/
    - Обслуживание рабочих БД (дефрагментация индексов, обновление статистики, очистка процедурного кэша) https://techlab.rarus.ru/news/articles/tipichnye-oshibki-nastroyki-planov-obsluzhivaniya-subd-ms-sql-dlya-1s/
    - База `tempdb` разбита на несколько файлов, в зависимости от ядер ЦП, задействованных сервером БД https://qastack.ru/dba/33448/splitting-tempdb-into-multiples-files-equal-to-number-of-cpus
    - обновления MS SQL и флаги трассировки: https://its.1c.ru/db/metod8dev/content/5904/hdoc и https://its.1c.ru/db/metod8dev/content/5946/hdoc
    - при необходимости воспользоваться для анализа скриптами из папки [sql_queries](sql_queries)