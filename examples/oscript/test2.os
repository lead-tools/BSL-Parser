
ПодключитьСценарий("..\..\src\ПарсерВстроенногоЯзыка\Ext\ObjectModule.bsl", "Парсер");
ПодключитьСценарий("..\plugins\ДетекторНеиспользуемыхПеременных\src\ДетекторНеиспользуемыхПеременных\Ext\ObjectModule.bsl", "ДетекторНеиспользуемыхПеременных");
ПодключитьСценарий("..\plugins\ДетекторОшибочныхЗамыкающихКомментариев\src\ДетекторОшибочныхЗамыкающихКомментариев\Ext\ObjectModule.bsl", "ДетекторОшибочныхЗамыкающихКомментариев");
ПодключитьСценарий("..\plugins\ДетекторФункцийБезВозвратаВКонце\src\ДетекторФункцийБезВозвратаВКонце\Ext\ObjectModule.bsl", "ДетекторФункцийБезВозвратаВКонце");

Если АргументыКоманднойСтроки.Количество() = 0 Тогда
	ВызватьИсключение "Укажите в качестве параметра путь к папке с общими модулями bsl";
КонецЕсли;

ПутьКМодулям = АргументыКоманднойСтроки[0];
Файлы = НайтиФайлы(ПутьКМодулям, "*.bsl", Истина);

Парсер = Новый Парсер;

Плагины = Новый Массив;
Плагины.Добавить(Новый ДетекторНеиспользуемыхПеременных);
Плагины.Добавить(Новый ДетекторОшибочныхЗамыкающихКомментариев);
Плагины.Добавить(Новый ДетекторФункцийБезВозвратаВКонце);

ЧтениеТекста = Новый ЧтениеТекста;

Отчет = Новый Массив;

Для Каждого Файл Из Файлы Цикл
	Если Файл.ЭтоФайл() Тогда
		ЧтениеТекста.Открыть(Файл.ПолноеИмя, "UTF-8");
		Исходник = ЧтениеТекста.Прочитать();
		Попытка
			Парсер.Пуск(Исходник, Плагины);
			Для Каждого Ошибка Из Парсер.ТаблицаОшибок() Цикл
				Отчет.Добавить(Символы.ПС);
				Отчет.Добавить(Файл.ПолноеИмя);
				Отчет.Добавить(Символы.ПС);
				Отчет.Добавить(Ошибка.Текст);
				Отчет.Добавить(СтрШаблон(" [стр: %1; кол: %2]", Ошибка.НомерСтрокиНачала, Ошибка.НомерКолонкиНачала));
				Отчет.Добавить(Символы.ПС);
			КонецЦикла;
		Исключение
			Отчет.Добавить(Символы.ПС);
			Отчет.Добавить(Файл.ПолноеИмя);
			Отчет.Добавить(Символы.ПС);
			Отчет.Добавить("ОШИБКА:");
			Отчет.Добавить(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			Отчет.Добавить(Символы.ПС);
		КонецПопытки;
		ЧтениеТекста.Закрыть();
	КонецЕсли;
КонецЦикла;

ЗаписьТекста = Новый ЗаписьТекста;
ЗаписьТекста.Открыть("Отчет.txt", "UTF-8");
ЗаписьТекста.Записать(СтрСоединить(Отчет));
ЗаписьТекста.Закрыть();

Сообщить("Проверка закончена. Отчет о проверке находится в файле 'Отчет.txt'");