﻿
#Область Служебные_функции_и_процедуры

&НаКлиенте
// контекст фреймворка Vanessa-Automation
Перем Ванесса;
 
&НаКлиенте
// Структура, в которой хранится состояние сценария между выполнением шагов. Очищается перед выполнением каждого сценария.
Перем Контекст Экспорт;
 
&НаКлиенте
// Структура, в которой можно хранить служебные данные между запусками сценариев. Существует, пока открыта форма Vanessa-Automation.
Перем КонтекстСохраняемый Экспорт;

&НаКлиенте
// Функция экспортирует список шагов, которые реализованы в данной внешней обработке.
Функция ПолучитьСписокТестов(КонтекстФреймворкаBDD) Экспорт
	Ванесса = КонтекстФреймворкаBDD;
	
	ВсеТесты = Новый Массив;

	//описание параметров
	//Ванесса.ДобавитьШагВМассивТестов(ВсеТесты,Снипет,ИмяПроцедуры,ПредставлениеТеста,ОписаниеШага,ТипШага,Транзакция,Параметр);

	Ванесса.ДобавитьШагВМассивТестов(ВсеТесты,"ВАЯВыгружаюЖРЗаПериодСПоСОтборомПоВКаталогВФайл(Парам01,Парам02,Парам03,Парам04,Парам05)","ВАЯВыгружаюЖРЗаПериодСПоСОтборомПоВКаталогВФайл","Допустим ВА Я выгружаю ЖР за период с ""ДатаНачала"" по ""ДатаОкончания"" с отбором по ""УровеньЖурналаРегистрации"" в каталог ""ИмяНовогоКаталога"" в файл ""ИмяФайла""","","");

	Возврат ВсеТесты;
КонецФункции
	
&НаСервере
// Служебная функция.
Функция ПолучитьМакетСервер(ИмяМакета)
	ОбъектСервер = РеквизитФормыВЗначение("Объект");
	Возврат ОбъектСервер.ПолучитьМакет(ИмяМакета);
КонецФункции
	
&НаКлиенте
// Служебная функция для подключения библиотеки создания fixtures.
Функция ПолучитьМакетОбработки(ИмяМакета) Экспорт
	Возврат ПолучитьМакетСервер(ИмяМакета);
КонецФункции

#КонецОбласти



#Область Работа_со_сценариями

&НаКлиенте
// Функция выполняется перед началом каждого сценария
Функция ПередНачаломСценария() Экспорт
	
КонецФункции

&НаКлиенте
// Функция выполняется перед окончанием каждого сценария
Функция ПередОкончаниемСценария() Экспорт
	
КонецФункции

#КонецОбласти


///////////////////////////////////////////////////
//Реализация шагов
///////////////////////////////////////////////////

&НаКлиенте
//Допустим ВА Я выгружаю ЖР за период с "ДатаНачала" по "ДатаОкончания" с отбором по "УровеньЖурналаРегистрации" в каталог "ИмяНовогоКаталога" в файл "ИмяФайла"
//@ВАЯВыгружаюЖРЗаПериодСПоСОтборомПоВКаталогВФайл(Парам01,Парам02,Парам03,Парам04,Парам05)
Функция ВАЯВыгружаюЖРЗаПериодСПоСОтборомПоВКаталогВФайл(Парам01,Парам02,Парам03,Парам04,Парам05) Экспорт
	
	ЯВыгружаюЖРЗаПериодСПоСОтборомПоВКаталогВФайл_НаСервере(Парам01, Парам02, Парам03, Парам04, Парам05, Контекст, Ванесса.Объект.КаталогПроекта);
	
КонецФункции

#Область СлужебныеПроцедурыФункции

&НаСервереБезКонтекста
Процедура ЯВыгружаюЖРЗаПериодСПоСОтборомПоВКаталогВФайл_НаСервере(Парам01, Парам02, Парам03, Парам04, Парам05, ТекКонтекст, КаталогПроекта)

	// подготовка параметров для анализа записей ЖР
	Если ТекКонтекст.Количество() > 0 И ТекКонтекст.Свойство(Парам01) Тогда		
		ДатаНачала = ТекКонтекст[Парам01];		
	Иначе		
		ВызватьИсключение "Не заполнена дата начала!";	
	КонецЕсли;
	
	Если ТекКонтекст.Количество() > 0 И ТекКонтекст.Свойство(Парам02) Тогда
		ДатаОкончания = ТекКонтекст[Парам02];
	Иначе
		ВызватьИсключение "Не заполнена дата окончания!";	
	КонецЕсли;
	
	Уровень = Неопределено;
	Если ТекКонтекст.Количество() > 0 И ТекКонтекст.Свойство(Парам03) Тогда
		УровеньСтрокой = ТекКонтекст[Парам03];
		Уровень = УровеньЖурналаРегистрации[УровеньСтрокой];
	Иначе
		ВызватьИсключение "Не заполнен уровень регистрации для выгрузки событий!";	
	КонецЕсли;	
	//
	
	// определение полного имени файла для сохранения
	Если ТекКонтекст.Количество() > 0 И ТекКонтекст.Свойство(Парам04) И ТекКонтекст.Свойство(Парам05) Тогда
		
		Если НЕ ЗначениеЗаполнено(КаталогПроекта) Тогда
			ВызватьИсключение "Не заполнен текущий каталог функциональности!";
		КонецЕсли;
		
		Если Прав(КаталогПроекта, 1) = "\" Тогда 
			ТекКаталогФункциональности = КаталогПроекта;
		Иначе
			ТекКаталогФункциональности = КаталогПроекта + "\";
		КонецЕсли;	
		
		НовКаталогСохранения = ТекКаталогФункциональности + ТекКонтекст[Парам04];
		
		ПроверкаКаталог = Новый Файл(НовКаталогСохранения);
		Если НЕ ПроверкаКаталог.Существует() Тогда
			СоздатьКаталог(НовКаталогСохранения);
		КонецЕсли;
		
		ПолноеИмяФайла = НовКаталогСохранения + "\" + ТекКонтекст[Парам05];
		
	Иначе
		
		ВызватьИсключение "Не заполнены имя каталога сохранения и имя файла сохранения!";
		
	КонецЕсли;	
	//
	
	// чтение записей ЖР
	ТзЗаписиЖР = Новый ТаблицаЗначений;
	
	Отбор = Новый Структура;
	Отбор.Вставить("ДатаНачала", ДатаНачала);
	Отбор.Вставить("ДатаОкончания", ДатаОкончания);
	Если ЗначениеЗаполнено(Уровень) Тогда
		Отбор.Вставить("Уровень", Уровень);
	КонецЕсли;	
	
	ВыгрузитьЖурналРегистрации(ТзЗаписиЖР, Отбор);
	//
		
	// сериализация результата
	Если ТзЗаписиЖР.Количество() = 0 Тогда
		
		ТекстСообщения = "По переданным отборам: " + Строка(ТекКонтекст[Парам01]) + "; " + Строка(ТекКонтекст[Парам02]) + "; " +
		Строка(ТекКонтекст[Парам03]) + " - записей в ЖР не обнаружено";
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения);
		
		СуществующийФайл = Новый Файл(ПолноеИмяФайла);
		Если СуществующийФайл.Существует() Тогда
			УдалитьФайлы(ПолноеИмяФайла);
		КонецЕсли;	
		
	Иначе		
		
		ТзЗаписиЖР_ДляСериализации = Новый ТаблицаЗначений;
		
		Для Каждого ТекКолонка Из ТзЗаписиЖР.Колонки Цикл
			ТзЗаписиЖР_ДляСериализации.Колонки.Добавить(ТекКолонка.Имя);
		КонецЦикла;
		
		Для Каждого ТСтр Из ТзЗаписиЖР Цикл
			
			НовСтр = ТзЗаписиЖР_ДляСериализации.Добавить();
			
			Для Каждого ТекКолонка Из ТзЗаписиЖР.Колонки Цикл
				НовСтр[ТекКолонка.Имя] = Строка(ТСтр[ТекКолонка.Имя]);				
			КонецЦикла;	
			
		КонецЦикла;
		
		СтрокаРезультат = Сериализовать(ТзЗаписиЖР_ДляСериализации);
		//
		
		// сохранение в файл
		ТекстДок = Новый ТекстовыйДокумент;
		ТекстДок.УстановитьТекст(СтрокаРезультат);
				
		Попытка
			ТекстДок.Записать(ПолноеИмяФайла, "UTF-8");			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Успешно записан новый файл: " + ПолноеИмяФайла);
		Исключение
			ВызватьИсключение "Не удалось записать новый файл по причине: " + Строка(ОписаниеОшибки());
		КонецПопытки;	
		//
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция Сериализовать(ОбъектСериализации) Экспорт
	
	ДеревоВОбъектеXDTO = СериализаторXDTO.ЗаписатьXDTO(ОбъектСериализации);
	XML = Новый ЗаписьXML;
	XML.УстановитьСтроку();
	ПараметрыЗаписиXML = Новый ПараметрыЗаписиXML("UTF-8", "1.0", Ложь); 
	ФабрикаXDTO.ЗаписатьXML(XML, ДеревоВОбъектеXDTO);
	
	Возврат XML.Закрыть()
	
КонецФункции

#КонецОбласти