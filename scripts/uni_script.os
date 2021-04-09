// TO-DO
// 1) Парсер командной строки с именованными параметрами
// 2) Поддерживаемые команды:
//		+ /DumpIB		Резервная копия с блокировкой сеансов
//			Параметры запуска:
//				- /F <путь> (тип базы - файловая)
//				- /S <адрес> (тип базы - серверная, <Имя компьютера, работающего сервером приложений>\<Ссылочное имя информационной базы, известное в рамках сервера 1С:Предприятия 8>)
//				- /N (логин администратора ИБ, если не задан, то без логина)
//				- /P (пароль администратора ИБ)
//				- /CN (логин администратора кластера серверов, если не задан, то не авторизоваться на кластере)
//				- /CP (пароль администратора кластера серверов)
//				- /UC (код блокировки, если не задано, то блокировка не ставится)
//				- /Format (формат имени файла бэкапа, если не задано, то будет использован формат "yyyyMMddHHmmss")
//				- /UCMsg (текст сообщения пользователям при блокировке работы ИБ)
//				- /LOG <имя файла> (не обязательный параметр, путь к файлу логов, записи добавляются в конец, в виде Дата, Тип сообщения([INFO ], [ERROR], [WARNG]), Сообщение)
//				- /UPath <путь> (Путь выгрузки ИБ)
//				- /UCount (количество копий, которые необходимо оставить)
//				- /Pref (префикс имя файла бэкапа)
// 	
//		+ /RestoreIB	Восстановление резервеной копии в ИБ
//				- /F <путь> (тип базы - файловая)
//				- /S <адрес> (тип базы - серверная, <Имя компьютера, работающего сервером приложений>\<Ссылочное имя информационной базы, известное в рамках сервера 1С:Предприятия 8>)
//				- /N (логин администратора ИБ, если не задан, то без логина)
//				- /P (пароль администратора ИБ)
//				- /CN (логин администратора кластера серверов, если не задан, то не авторизоваться на кластере)
//				- /CP (пароль администратора кластера серверов)
//				- /UC (код блокировки)
//				- /UCMsg (Текст сообщения пользователям при блокировке работы ИБ)
//				- /LOG <имя файла> (не обязательный параметр, путь к файлу логов, записи добавляются в конец, в виде Дата, Тип сообщения([INFO ], [ERROR], [WARNG]), Сообщение)
//				- /UPath <путь> (Путь к файлу dt)
//
//		+ /Lock			Блокировка сеансов пользователей
//			Параметры запуска:
//				- /F <путь> (тип базы - файловая)
//				- /S <адрес> (тип базы - серверная, <Имя компьютера, работающего сервером приложений>\<Ссылочное имя информационной базы, известное в рамках сервера 1С:Предприятия 8>)
//				- /N (логин админситратора ИБ, если не задан, то без логина)
//				- /P (пароль администратора ИБ)
//				- /UC (код блокировки, если не задано, то блокировка не ставится)
//				- /UCMsg (Текст сообщения пользователям при блокировке работы ИБ)
//				- /LOG
//				- /LockBegin (время начала блокировки сеансов)
//				- /LockEnd (время окончания блокировки сеансов)
//
//		+ /Unlock		Разблокировка сеансов пользователей
//			Параметры запуска:
//				- /F <путь> (тип базы - файловая)
//				- /S <адрес> (тип базы - серверная, <Имя компьютера, работающего сервером приложений>\<Ссылочное имя информационной базы, известное в рамках сервера 1С:Предприятия 8>)
//				- /N (логин админситратора ИБ, если не задан, то без логина)
//				- /P (пароль администратора ИБ)
//				- /LOG
//
//		+ /Terminate	Прерывание сеансов работы пользователей по условиями или без
//			Параметры запуска:
//				- /F <путь> (тип базы - файловая)
//				- /S <адрес> (тип базы - серверная, <Имя компьютера, работающего сервером приложений>\<Ссылочное имя информационной базы, известное в рамках сервера 1С:Предприятия 8>)
//				- /N (логин админситратора ИБ, если не задан, то без логина)
//				- /P (пароль администратора ИБ)
//				- /CN (логин администратора кластера серверов, если не задан, то не авторизоваться на кластере)
//				- /CP (пароль администратора кластера серверов)
//				- /UTime (время в секундах, для удаления устаревших сеансов)
//				- /LOG
//
//		+ /ClearOldFiles Удаление файлов по заданной маске с учетом последней даты изменения (устаревших)
//			Параметры запуска:
//				- /UPath <путь> (каталог с файлами)
//				- /UMask <маска> (маска имени файла для отбора файлов)
//				- /UCount <количество> (количество файлов, которые необходимо оставить)

#Использовать v8runner
#Использовать cmdline

Перем юсКонфигуратор;
Перем юсПарсер;
Перем юсПараметры;

Процедура ЗадатьНачальныеНастройки()	
	
	юсКонфигуратор 				= Новый УправлениеКонфигуратором();
	юсПарсер 					= Новый ПарсерАргументовКоманднойСтроки();
	юсПараметры					= ЗаполнитьПараметры();	
	
	Если АргументыКоманднойСтроки.Количество() = 0 Тогда		
		юсСообщить("ERROR", "Не заданы аргументы командной строки!");		
		ЗавершитьРаботу(1);
	КонецЕсли;	
	
КонецПроцедуры

Функция ЗаполнитьПараметры()
	
	юсПарсер.ДобавитьПараметр("ИмяКоманды"); 			// Имя команды 
	юсПарсер.ДобавитьИменованныйПараметр("/F");			// База файловая
	юсПарсер.ДобавитьИменованныйПараметр("/S");			// База серверная
	юсПарсер.ДобавитьИменованныйПараметр("/N");			// Логин админиcтратора ИБ
	юсПарсер.ДобавитьИменованныйПараметр("/P"); 		// Пароль администратора ИБ
	юсПарсер.ДобавитьИменованныйПараметр("/CN"); 		// Логин администратора кластера серверов
	юсПарсер.ДобавитьИменованныйПараметр("/CP"); 		// Пароль администратора кластера серверов
	юсПарсер.ДобавитьИменованныйПараметр("/UC");		// Код блокировки
	юсПарсер.ДобавитьИменованныйПараметр("/Format");	// Формат имение бэкапа
	юсПарсер.ДобавитьИменованныйПараметр("/UCMsg");		// Текст сообщения пользователям
	юсПарсер.ДобавитьИменованныйПараметр("/LOG");		// Сохранять лог - файл
	юсПарсер.ДобавитьИменованныйПараметр("/UTime");		// Время в секундах
	юсПарсер.ДобавитьИменованныйПараметр("/UPath");		// Путь сохранения
	юсПарсер.ДобавитьИменованныйПараметр("/LockBegin");	// Время начала блокировки сеансов
	юсПарсер.ДобавитьИменованныйПараметр("/LockEnd");	// Время окончания блокировки сеансов
	юсПарсер.ДобавитьИменованныйПараметр("/UCount");	// Количество копий, которые необходимо оставить после бэкапа
	юсПарсер.ДобавитьИменованныйПараметр("/Pref");		// Префикс имени файла бэкапа
	юсПарсер.ДобавитьИменованныйПараметр("/UMask");		// Маска имени файла
		
	Возврат юсПарсер.Разобрать(АргументыКоманднойСтроки);	 
	
КонецФункции

Процедура ИнициализацияСистемныхПеременных()

	СтрокаПодключения 		= "";
	ПутьКБазе				= "";
	ИмяАдминистратораИБ 	= ?(юсПараметры["/N"] <> Неопределено, юсПараметры["/N"], "");
	ПарольАдминистратораИБ 	= ?(юсПараметры["/P"] <> Неопределено, юсПараметры["/P"], "");
	КодРазрешения			= ?(юсПараметры["/UC"] <> Неопределено, юсПараметры["/UC"], "");	
	
	Если юсПараметры["/S"] <> Неопределено Тогда
		мПутьКБазе				= юсПараметры["/S"];
		ИмяСервера 				= Лев(мПутьКБазе, Найти(мПутьКБазе,"\") - 1);
		ИмяБазы					= Прав(мПутьКБазе, СтрДлина(мПутьКБазе) - Найти(мПутьКБазе,"\"));
		ПутьКБазе				= "/S""" + мПутьКБазе + """";				
		СтрокаПодключения		= "Srvr=""" + ИмяСервера + """;Ref=""" + ИмяБазы + """;";
		юсСообщить("INFO ", "Начало работы с базой """ + ИмяБазы + """");
	Иначе
		ПутьКБазе			= "/F""" + юсПараметры["/F"] + """";
		СтрокаПодключения	= "File=""" + юсПараметры["/F"] + """;";
		юсСообщить("INFO ", "Начало работы с базой """ + юсПараметры["/F"] + """");
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ИмяАдминистратораИБ) Тогда
		СтрокаПодключения = СтрокаПодключения + "Usr=""" + ИмяАдминистратораИБ + """;";
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ПарольАдминистратораИБ) Тогда
		СтрокаПодключения = СтрокаПодключения + "Pwd=""" + ПарольАдминистратораИБ + """;";
	КонецЕсли;
	
	юсКонфигуратор.УстановитьКонтекст(ПутьКБазе, ИмяАдминистратораИБ, ПарольАдминистратораИБ);
	
	Если ЗначениеЗаполнено(КодРазрешения) Тогда 
		СтрокаПодключения = СтрокаПодключения + "UC=""" + КодРазрешения + """;";
		юсКонфигуратор.УстановитьКлючРазрешенияЗапуска(КодРазрешения);
	КонецЕсли;
	
	СтрокаПодключения = Сред(СтрокаПодключения,1,СтрДлина(СтрокаПодключения) - 1);	
	
	юсПараметры.Вставить("ПутьКБазе", ПутьКБазе);
	юсПараметры.Вставить("СтрокаПодключения", СтрокаПодключения);
	юсПараметры.Вставить("ИмяСервера", ИмяСервера);
	юсПараметры.Вставить("ИмяБазы", ИмяБазы);
	
КонецПроцедуры

Функция ДополнитьСтрокуСлешем(Знач Стр)
	
	Если ПустаяСтрока(Стр) Тогда
		Возврат "\";
	КонецЕсли;
	
	Возврат Стр + ?(Прав(Стр, 1) = "\", "", "\");
	
КонецФункции

Процедура УстановитьБлокировкуСеансов()
	
	Соединение 			= Неопределено;
	СтрокаПодключения 	= юсПараметры["СтрокаПодключения"];
	ВремяНачала			= юсПараметры["/LockBegin"];
	ВремяОкончания		= юсПараметры["/LockEnd"];
	КодРазрешения		= юсПараметры["/UC"];
	Сообщение			= юсПараметры["/UCMsg"];
	V8 					= Новый COMObject("V83.COMConnector");
	
	Попытка
		Соединение 				= V8.Connect(СтрокаПодключения);
		Блокировка 				= Соединение.NewObject("БлокировкаСеансов");
		Блокировка.Установлена	= Истина;

		Если ЗначениеЗаполнено(ВремяНачала) Тогда
			Блокировка.Начало 	= ВремяНачала;
		Иначе
			Блокировка.Начало 	= ТекущаяДата();
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ВремяОкончания) Тогда
			Блокировка.Конец 	= ВремяОкончания;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(КодРазрешения) Тогда 
			Блокировка.КодРазрешения= КодРазрешения;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Сообщение) Тогда	
			Блокировка.Сообщение= Сообщение;
		КонецЕсли;	
		
		Соединение.УстановитьБлокировкуСеансов(Блокировка);
		
		юсСообщить("INFO ", "Блокировка сеансов установлена");
	Исключение
		юсСообщить("ERROR", "При установке блокировки возникла ошибка: " + ОписаниеОшибки());
	КонецПопытки;
	
	Соединение 	= Неопределено;
	V8			= Неопределено;
	
КонецПроцедуры

Процедура ПрерватьСеансыПользователей()
	
	ИмяСервера					= юсПараметры["ИмяСервера"];	
	ИмяБазы						= юсПараметры["ИмяБазы"];
	ИмяАдминистратораИБ			= юсПараметры["/N"];
	ПарольАдминистратораИБ 		= юсПараметры["/P"];	
	ИмяАдминистратораКластера 	= юсПараметры["/CN"];
	ПарольАдминистратораКластера= юсПараметры["/CP"];
	ВремяПростоя				= юсПараметры["/UTime"];
	Соединение 					= Неопределено;
	V8 							= Новый COMObject("V83.COMConnector");	
	Попытка		
		Агент 	 = V8.ConnectAgent(ИмяСервера);
		Кластеры = Агент.GetClusters();
		Для Каждого Кластер из Кластеры Цикл
			
			Если ЗначениеЗаполнено(ИмяАдминистратораКластера) И ЗначениеЗаполнено(ПарольАдминистратораКластера) Тогда
				Агент.Authenticate(Кластер, ИмяАдминистратораКластера, ИмяАдминистратораКластера);
			ИначеЕсли ЗначениеЗаполнено(ИмяАдминистратораКластера) Тогда
				Агент.Authenticate(Кластер,ИмяАдминистратораКластера,"");
			Иначе 
				Агент.Authenticate(Кластер,"","");
			КонецЕсли;
			
			Процессы = Агент.GetWorkingProcesses(Кластер);
			
			Для Каждого Процесс из Процессы Цикл
				Порт 	= Процесс.MainPort;
				// теперь есть адрес и порт для подключения к рабочему процессу
				РабПроц = V8.ConnectWorkingProcess(ИмяСервера + ":" + СтрЗаменить(Порт, Символы.НПП, ""));
				РабПроц.AddAuthentication(ИмяАдминистратораИБ, ПарольАдминистратораИБ);
				ИнформационнаяБаза = "";
				Базы 	= Агент.GetInfoBases(Кластер);				
				Для Каждого База из Базы Цикл
					Если ВРег(База.Name) = ВРег(ИмяБазы) Тогда
						ИнформационнаяБаза = База;
						Прервать;
					КонецЕсли;
				КонецЦикла;				
				
				Если ИнформационнаяБаза = "" Тогда
					юсСообщить("ERROR", "ИБ не найдена!");
					ЗавершитьРаботу(1);
				КонецЕсли;				
				
				Сеансы = Агент.GetInfoBaseSessions(Кластер, ИнформационнаяБаза);
				Для Каждого Сеанс из Сеансы Цикл
					//Если нРег(Сеанс.AppID) = "backgroundjob" ИЛИ нРег(Сеанс.AppID) = "comconsole" ИЛИ нРег(Сеанс.AppID) = "designer" Тогда
					// если это сеансы конфигуратора или фонового задания, то не отключаем
					
					Если нРег(Сеанс.AppID) = "comconsole" Тогда					
						Продолжить;
					КонецЕсли;
					
					//Если Сеанс.UserName = ИмяПользователя() Тогда
						// это текущий пользователь
						//Продолжить;
					//КонецЕсли;
					
					Если ЗначениеЗаполнено(ВремяПростоя) Тогда						
						КонтрольнаяДата = ТекущаяДата() - Число(ВремяПростоя);
						Если Сеанс.LastActiveAt < КонтрольнаяДата Тогда
							Агент.TerminateSession(Кластер, Сеанс);
							юсСообщить("INFO ","Сеанс " + Сеанс.UserName +" " + Сеанс.AppID +" отключен");		
						КонецЕсли;
					Иначе
						Агент.TerminateSession(Кластер, Сеанс);
						юсСообщить("INFO ", "Сеанс " + Сеанс.UserName +" " + Сеанс.AppID +" отключен");		
					КонецЕсли;					
				КонецЦикла;
				
				//СоединенияБазы = Агент.GetInfoBaseConnections(Кластер, ИнформационнаяБаза);
				Шаблон 	 		= РабПроц.CreateInfoBaseInfo();
				Шаблон.Name 	= ИмяБазы;
								
				Попытка
					СоединенияБазы 	= РабПроц.GetInfoBaseConnections(Шаблон);
				Исключение
					СоединенияБазы = Неопределено;
				КонецПопытки;		 
								
				// Разорвать соединения клиентских приложений.
				Если СоединенияБазы <> Неопределено И Не ЗначениеЗаполнено(ВремяПростоя) Тогда
					Для Каждого мСоединение Из СоединенияБазы Цикл
						//Если нРег(Соединение.Application) = "backgroundjob" ИЛИ нРег(Соединение.Application) = "designer" Тогда
						// если это соединение конфигуратора или фонового задания, то не отключаем
						Если нРег(мСоединение.AppID) = "designer" Тогда 
							Продолжить;
						КонецЕсли;
						//Если мСоединение.UserName = ИмяПользователя() Тогда
						//	// это текущий пользователь
						//	Продолжить;
						//КонецЕсли;
						Попытка
							РабПроц.Disconnect(мСоединение);
							юсСообщить("INFO ", "Соединение " + мСоединение.UserName + " " +мСоединение.AppID+ " отключено");
						Исключение
						юсСообщить("ERROR", "Ошибка при отключении соединения: " + ОписаниеОшибки());
						КонецПопытки;					
					КонецЦикла;
				КонецЕсли;
			КонецЦикла;
		КонецЦикла;		
	Исключение
		юсСообщить("ERROR", "Не удалось установить соединение!" + ОписаниеОшибки());		
	КонецПопытки;
	
	Соединение  = Неопределено;		
	V8			= Неопределено;
	юсСообщить("INFO ", "Завершение сеансов выполнено");
	
КонецПроцедуры

Процедура ЗагрузитьИБИзФайла()		
	
	ПутьСохранения 		= юсПараметры["/UPath"];	
	ПараметрыЗапуска 	= юсКонфигуратор.ПолучитьПараметрыЗапуска();	
	ПараметрыЗапуска.Добавить("/RestoreIB " + ПутьСохранения);	
	юсСообщить("INFO ", "Начало загрузки...");
	Попытка	
	    юсКонфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);
		юсСообщить("INFO ", "Загрузка завершена");
	Исключение												   
		юсСообщить("ERROR", "Произошла ошибка при выгрузке " + юсКонфигуратор.ВыводКоманды());
	КонецПопытки
	
КонецПроцедуры

Процедура ВыгрузитьИБВФайл()		
	
	ПутьСохранения 				= юсПараметры["/UPath"];	
	ФорматИмениРезервнойКопии 	= ?(юсПараметры["/Format"] <> Неопределено, юсПараметры["/Format"], "yyyyMMddHHmmss");
	ИмяБазы						= юсПараметры["ИмяБазы"];
	Префикс						= юсПараметры["/Pref"];

	Если ЗначениеЗаполнено(Префикс) Тогда
		ПолныйПутьСохранения 	= ДополнитьСтрокуСлешем(ПутьСохранения) + Префикс + Формат(ТекущаяДата(), "ДФ=" + ФорматИмениРезервнойКопии) + ".dt";
	Иначе
		ПолныйПутьСохранения 	= ДополнитьСтрокуСлешем(ПутьСохранения) + ИмяБазы + Формат(ТекущаяДата(), "ДФ=" + ФорматИмениРезервнойКопии) + ".dt";
	КонецЕсли;
			
	// Делаем копию
	ПараметрыЗапуска 			= юсКонфигуратор.ПолучитьПараметрыЗапуска();
	ПараметрыЗапуска.Добавить("/DumpIB""" + ПолныйПутьСохранения + """"); 	
	юсСообщить("INFO ", "Начало выгрузки");
	Попытка
	    юсКонфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);
		юсСообщить("INFO ", "Выгрузка завершена");
	Исключение												   
		юсСообщить("ERROR", "Произошла ошибка при выгрузке " + юсКонфигуратор.ВыводКоманды());		
	КонецПопытки;
		
КонецПроцедуры

Процедура СнятьБлокировкуСеансов()
	
	Соединение 			= Неопределено;
	СтрокаПодключения 	= юсПараметры["СтрокаПодключения"];
	V8 					= Новый COMObject("V83.COMConnector");	
	Попытка
		Соединение 	= V8.Connect(СтрокаПодключения);	
		ТекущийРежим= Соединение.ПолучитьБлокировкуСеансов();	
		Если ТекущийРежим.Установлена Тогда
			НовыйРежим 				= Соединение.NewObject("БлокировкаСеансов");
			НовыйРежим.Установлена 	= Ложь;
			Соединение.УстановитьБлокировкуСеансов(НовыйРежим);
		КонецЕсли;
		юсСообщить("INFO ", "Блокировка сеансов отключена");
	Исключение
		юсСообщить("ERROR", "Не удалось установить соединение!");		
	КонецПопытки;					
	Соединение  = Неопределено;
	V8			= Неопределено;
	
КонецПроцедуры

Процедура юсВыполнитьКоманду()
	
	ИмяКоманды 			= юсПараметры["ИмяКоманды"];
	ПутьКБазеСерверной 	= юсПараметры["/S"];
	ПутьКБазеФайловой 	= юсПараметры["/F"];
	
	Если ВРег(ИмяКоманды) = "/RESTOREIB" Тогда		
		Если ЗначениеЗаполнено(ПутьКБазеСерверной) Тогда
			УстановитьБлокировкуСеансов();
			ПрерватьСеансыПользователей();
			ЗагрузитьИБИзФайла();
			СнятьБлокировкуСеансов();
		Иначе
			ЗагрузитьИБИзФайла();		
		КонецЕсли;		
	КонецЕсли;
	
	Если ВРег(ИмяКоманды) = "/DUMPIB" Тогда
		Если ЗначениеЗаполнено(ПутьКБазеСерверной) Тогда
			УстановитьБлокировкуСеансов();
			ПрерватьСеансыПользователей();
			ВыгрузитьИБВФайл();			
			СнятьБлокировкуСеансов();
			юсУдалитьФайлы();
		Иначе
			ВыгрузитьИБВФайл();
		КонецЕсли;			
	КонецЕсли;
	
	Если ВРег(ИмяКоманды) = "/LOCK" Тогда
		УстановитьБлокировкуСеансов();		
	КонецЕсли;
	
	Если ВРег(ИмяКоманды) = "/UNLOCK" Тогда
		СнятьБлокировкуСеансов();		
	КонецЕсли;
	
	Если ВРег(ИмяКоманды) = "/TERMINATE" Тогда
		ПрерватьСеансыПользователей();		
	КонецЕсли;
	
	Если ВРег(ИмяКоманды) = "/CLEAROLDFILES" Тогда
		юсУдалитьФайлы();		
	КонецЕсли;
	
КонецПроцедуры

Процедура юсСообщить(ТипСообщения, ТекстСообщения)
	
	ИмяЛогФайла 	= юсПараметры["/LOG"];
	ТекстСообщения 	= "[" + ТекущаяДата() + "] " + "[" + ТипСообщения + "] " + ТекстСообщения;
	
	Если ЗначениеЗаполнено(ИмяЛогФайла) Тогда
		ВЛогФайл(ИмяЛогФайла, ТекстСообщения);
	Иначе
		Сообщить(ТекстСообщения);
	КонецЕсли;
	
КонецПроцедуры	

Функция ВЛогфайл(ИмяФайла, ТекстСообщения)
	
	Если Найти(ИмяФайла, "\") = 0 Тогда
        ИмяФайла = КаталогПрограммы() + ИмяФайла;
        Сообщить("Лог:" + ИмяФайла);
    КонецЕсли;
	
	ТекстовыйДокумент 	= Новый ТекстовыйДокумент;
    Кодировка 			= "UTF-8" ;
    юсРазделительСтрок 	= Символы.ВК + Символы.ПС;
	
	МассивФайлов 		= НайтиФайлы(ИмяФайла);
	// если файл еще не создан добавим строку
    Если МассивФайлов.Количество() = 0 Тогда        
        ТекстовыйДокумент.ДобавитьСтроку(ТекстСообщения);    
    Иначе 
        // если файл с таким именем уже создан прочитаем его
        ТекстовыйДокумент.Прочитать(ИмяФайла, Кодировка);
		ТекстовыйДокумент.ДобавитьСтроку(ТекстСообщения);
    КонецЕсли;	
    // закрываем ТекстовыйДокумент файл
    ТекстовыйДокумент.Записать(ИмяФайла, Кодировка);
	
КонецФункции

Процедура юсУдалитьФайлы()
	
	ПутьСохранения 				= юсПараметры["/UPath"];	
	Префикс						= юсПараметры["/Pref"];
	КоличествоХранимыхАрхивов	= Число(юсПараметры["/UCount"]);
	МаскаФайла					= юсПараметры["/UMask"];
	
	Если КоличествоХранимыхАрхивов <> Неопределено Тогда
		
		Если ЗначениеЗаполнено(МаскаФайла) Тогда
			МассивФайлов = НайтиФайлы(ПутьСохранения, МаскаФайла);
		ИначеЕсли ЗначениеЗаполнено(Префикс) Тогда
			МассивФайлов = НайтиФайлы(ПутьСохранения, Префикс + "*.dt");
		Иначе
			МассивФайлов = НайтиФайлы(ПутьСохранения, "*.dt");
		КонецЕсли;	
		
		Если МассивФайлов.Количество() > КоличествоХранимыхАрхивов Тогда
			ТЗ = Новый ТаблицаЗначений;
			ТЗ.Колонки.Добавить("Файл");
			ТЗ.Колонки.Добавить("ПоследняяДатаИзменения");
			Для Каждого Файл Из МассивФайлов Цикл
				СтрокаТЗ 						= ТЗ.Добавить();
				СтрокаТЗ.Файл 					= Файл.ПолноеИмя;
				СтрокаТЗ.ПоследняяДатаИзменения = Файл.ПолучитьВремяИзменения();				
			КонецЦикла;
			ТЗ.Сортировать("ПоследняяДатаИзменения Убыв");
			Пока ТЗ.Количество() > КоличествоХранимыхАрхивов Цикл
				Попытка
					мФайл	= ТЗ[ТЗ.Количество() - 1].Файл;
					УдалитьФайлы(мФайл);
					ТЗ.Удалить(ТЗ.Количество() - 1);
				Исключение
					юсСообщить("ERROR", "Произошла ошибка при удалении файла " + мФайл + " " + ОписаниеОшибки());
					Возврат;
				КонецПопытки;
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры	

ЗадатьНачальныеНастройки();
ИнициализацияСистемныхПеременных();
юсВыполнитьКоманду();