# Пожарный датчик дыма

Это учебный STDL-проект простого пожарного дымового датчика.

Проект специально сделан очень простым по форме, но в нем собраны ключевые механики, которые уже разбирались:

- `metadata`
- группы параметров
- `UserEnum`
- `Id`
- 3D-геометрия
- 2D-символика
- электрические порты
- `Placement3D`
- `SetVisible()`

Файлы:

- `parameters.json`
- `main.lua`
- `metodichka.md`

Сборка из корня проекта:

```powershell
.\RengaSTDLSDK\RstBuilder\RstBuilder.exe .\03-smoke_detector\parameters.json .\03-smoke_detector\main.lua -s 1.0 -o .\03-smoke_detector\smoke-detector.rst
```
