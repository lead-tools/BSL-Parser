
ПодключитьСценарий("..\..\src\ПарсерВстроенногоЯзыка\Ext\ObjectModule.bsl", "Парсер");
ПодключитьСценарий(".\Тестер\src\Тестер\Ext\ObjectModule.bsl", "Тестер");

Парсер = New Парсер;
Тестер = New Тестер;

Тестер.Пуск(Парсер);