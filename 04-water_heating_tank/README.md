# Нагревательный бак для воды

Это учебный STDL-проект накопительного водонагревательного бака.

Файлы проекта:

- `parameters.json` - параметры стиля и порты
- `main.lua` - геометрия, символика и настройка портов
- `metodichka.md` - пошаговое объяснение примера

Сборка из корня проекта:

```powershell
.\RengaSTDLSDK\RstBuilder\RstBuilder.exe .\04-water_heating_tank\parameters.json .\04-water_heating_tank\main.lua -s 1.0 -o .\04-water_heating_tank\water-heating-tank.rst
```

Проверка без создания `RST`:

```powershell
.\RengaSTDLSDK\RstBuilder\RstBuilder.exe .\04-water_heating_tank\parameters.json .\04-water_heating_tank\main.lua -s 1.0
```
