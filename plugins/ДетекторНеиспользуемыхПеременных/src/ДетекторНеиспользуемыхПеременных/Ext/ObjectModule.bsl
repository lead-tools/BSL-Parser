﻿
 // Плагин для проверки использования переменных и параметров.
 // Отслеживаются следующие ситуации:
 // - значение переменной не читается после присваивания (объявление тоже считается присваиванием)
 // - значение параметра-значения не читается после присваивания
 // - к параметру-ссылке нет обращений
 //
 // примечания:
 // Анализ в целом выполняется поверхностно и возможны ложные срабатывания.

 // todo: проверять два присваивания одной переменной подряд

Перем Узлы;
Перем Счетчики;
Перем ТаблицаОшибок;
Перем ТаблицаТокенов;
Перем Результат;

Перем Переменные, Параметры, ЛевыйОперандПрисваивания, Места;

Процедура Инициализировать(Парсер, Параметры) Экспорт
	Узлы = Парсер.Узлы();
	Счетчики = Парсер.Счетчики();
	ТаблицаОшибок = Парсер.ТаблицаОшибок();
	ТаблицаТокенов = Парсер.ТаблицаТокенов();
	Результат = Новый Массив;
	Переменные = Новый Соответствие;
	Параметры = Новый Соответствие;
	Места = Новый Соответствие;
КонецПроцедуры // Инициализировать()

Функция Закрыть() Экспорт
	Возврат СтрСоединить(Результат, Символы.ПС);
КонецФункции // Закрыть()

Функция Подписки() Экспорт
	Перем Подписки;
	Подписки = Новый Массив;
	Подписки.Добавить("ПосетитьОператорПрисваивания");
	Подписки.Добавить("ПокинутьОператорПрисваивания");
	Подписки.Добавить("ПосетитьВыражениеИдентификатор");
	Подписки.Добавить("ПосетитьОбъявлениеМетода");
	Подписки.Добавить("ПокинутьОбъявлениеМетода");
	Возврат Подписки;
КонецФункции // Подписки()

Процедура ПосетитьОператорПрисваивания(ОператорПрисваивания) Экспорт
	ЛевыйОперандПрисваивания = ОператорПрисваивания.ЛевыйОперанд;
КонецПроцедуры // ПосетитьОператорПрисваивания()

Процедура ПокинутьОператорПрисваивания(ОператорПрисваивания) Экспорт
	Перем Объявление, Операция;
	Если ОператорПрисваивания.ЛевыйОперанд.Аргументы <> Неопределено Или ОператорПрисваивания.ЛевыйОперанд.Хвост.Count() > 0 Тогда
		Возврат ;
	КонецЕсли;
	Объявление = ОператорПрисваивания.ЛевыйОперанд.Голова.Объявление;
	Места[Объявление] = ОператорПрисваивания.Начало;
	ЛевыйОперандПрисваивания = Неопределено;
	Операция = Переменные[Объявление];
	Если Операция <> Неопределено Тогда
		Если Операция <> "ЧтениеВЦикле" Или УровеньЦикла(Счетчики) = 0 Тогда
			Переменные[Объявление] = "Изменение";
		КонецЕсли;
	Иначе
		Операция = Параметры[Объявление];
		Если Операция <> Неопределено Тогда
			Если Операция <> "ЧтениеВЦикле" Или УровеньЦикла(Счетчики) = 0 Тогда
				Параметры[Объявление] = "Изменение";
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры // ПокинутьОператорПрисваивания()

Процедура ПосетитьВыражениеИдентификатор(ВыражениеИдентификатор) Экспорт
	Перем Объявление, Операция;
	Если ВыражениеИдентификатор.Хвост.Количество() = 0
		И ВыражениеИдентификатор = ЛевыйОперандПрисваивания Тогда
		Возврат ;
	КонецЕсли;
	Объявление = ВыражениеИдентификатор.Голова.Объявление;
	Если УровеньЦикла(Счетчики) > 0 Тогда
		Операция = "ЧтениеВЦикле";
	Иначе
		Операция = "Чтение";
	КонецЕсли;
	Если Переменные[Объявление] <> Неопределено Тогда
		Переменные[Объявление] = Операция;
	ИначеЕсли Параметры[Объявление] <> Неопределено Тогда
		Параметры[Объявление] = Операция;
	КонецЕсли;
КонецПроцедуры // ПосетитьВыражениеИдентификатор()

Процедура ПосетитьОбъявлениеМетода(ОбъявлениеМетода) Экспорт
	Переменные = Новый Соответствие;
	Параметры = Новый Соответствие;
	Для Каждого Параметр Из ОбъявлениеМетода.Сигнатура.Параметры Цикл
		Параметры[Параметр] = "Чтение";
		//Параметры[Параметр] = "Неопределено"; <- чтобы чекать все параметры (в формах адъ)
	КонецЦикла;
	Для Каждого ОбъявлениеПеременной Из ОбъявлениеМетода.Переменные Цикл
		Переменные[ОбъявлениеПеременной] = "Изменение";
		Места[ОбъявлениеПеременной] = ОбъявлениеПеременной.Начало;
	КонецЦикла;
	Для Каждого AutoОбъявление Из ОбъявлениеМетода.АвтоПеременные Цикл
		Переменные[AutoОбъявление] = "Изменение";
	КонецЦикла;
КонецПроцедуры // ПосетитьОбъявлениеМетода()

Процедура ПокинутьОбъявлениеМетода(ОбъявлениеМетода) Экспорт
	Перем Метод, Текст;
	Если ОбъявлениеМетода.Сигнатура.Тип = Узлы.СигнатураФункции Тогда
		Метод = "Функция";
	Иначе
		Метод = "Процедура";
	КонецЕсли;
	Для Каждого Элемент Из Переменные Цикл
		Если Не СтрНачинаетсяС(Элемент.Значение, "Чтение") Тогда
			Текст = СтрШаблон("%1 `%2()` содержит неиспользуемую переменную `%3`", Метод, ОбъявлениеМетода.Сигнатура.Имя, Элемент.Ключ.Имя);
			Ошибка(Текст, Места[Элемент.Ключ]);
		КонецЕсли;
	КонецЦикла;
	Для Каждого Элемент Из Параметры Цикл
		Если Элемент.Значение = "Неопределено" Или Элемент.Значение = "Изменение" И Элемент.Ключ.ПоЗначению Тогда
			Текст = СтрШаблон("%1 `%2()` содержит неиспользуемый параметр `%3`", Метод, ОбъявлениеМетода.Сигнатура.Имя, Элемент.Ключ.Имя);
			Ошибка(Текст, Места[Элемент.Ключ]);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

Функция УровеньЦикла(Счетчики)
	Возврат Счетчики[Узлы.ОператорПока] + Счетчики[Узлы.ОператорДляКаждого] + Счетчики[Узлы.ОператорДля];
КонецФункции

Процедура Ошибка(Текст, ИндексНачала, ИндексКонца = Неопределено)
	Начало = ТаблицаТокенов[ИндексНачала];
	Ошибка = ТаблицаОшибок.Добавить();
	Ошибка.Источник = "ДетекторНеиспользуемыхПеременных";
	Ошибка.Текст = Текст;
	Ошибка.ПозицияНачала = Начало.Начало;
	Ошибка.НомерСтрокиНачала = Начало.НомерСтроки;
	Ошибка.НомерКолонкиНачала = Начало.НомерКолонки;
	Если ИндексКонца = Неопределено Или ИндексКонца = ИндексНачала Тогда
		Ошибка.ПозицияКонца = Начало.Конец;
		Ошибка.НомерСтрокиКонца = Начало.НомерСтроки;
		Ошибка.НомерКолонкиКонца = Начало.НомерКолонки + Начало.Длина;
	Иначе
		Конец = ТаблицаТокенов[ИндексКонца];
		Ошибка.ПозицияКонца = Конец.Конец;
		Ошибка.НомерСтрокиКонца = Конец.НомерСтроки;
		Ошибка.НомерКолонкиКонца = Конец.НомерКолонки + Конец.Длина;
	КонецЕсли;
КонецПроцедуры

