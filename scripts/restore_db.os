#Использовать sql

Соединение = Новый Соединение();
Соединение.ТипСУБД = Соединение.ТипыСУБД.MSSQLServer;
Соединение.СтрокаСоединения = "Data Source=ServerDB_Name; Initial Catalog=ERP_Demo; User Id=; Password=; Trusted_Connection=Yes";
РезультатПодключения = Соединение.Открыть();

Если РезультатПодключения Тогда
	
	Сообщить("Подключение к серверу БД установлено. Начинаю восстановление целевой БД из бэкапа...");

	Запрос = Новый Запрос();	
	Запрос.УстановитьСоединение(Соединение);
	Запрос.Таймаут = 900; // время в секундах, необходимое для восстановления БД
	
	Запрос.Текст = 
	"USE [master];
	|ALTER DATABASE [ERP_Demo] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	|RESTORE DATABASE [ERP_Demo] FROM DISK = N'\\ServerDB_Name\bckp\ERP_Demo.bak' WITH FILE = 1, NOUNLOAD, REPLACE, STATS = 5;
	|ALTER DATABASE [ERP_Demo] SET MULTI_USER";
	
	Запрос.Выполнить();

	Сообщить("Целевая БД успешно восстановлена из резервной копии!");	

Иначе
	
	Сообщить("Не удалось установить подключение к серверу БД!");

КонецЕсли;