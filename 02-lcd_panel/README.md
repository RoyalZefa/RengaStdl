# LCD панель

Это очень простой учебный STDL-проект.

Что в нем есть:

- прямоугольный корпус
- прямоугольный экран
- переключение между настенным и настольным вариантом
- простая условная 2D-графика
- скрытие лишнего параметра через `SetVisible()`

Файлы:

- `parameters.json`
- `main.lua`
- `metodichka.md`

Сборка из корня проекта:

```powershell
.\RengaSTDLSDK\RstBuilder\RstBuilder.exe .\02-lcd_panel\parameters.json .\02-lcd_panel\main.lua -s 1.0 -o .\02-lcd_panel\lcd-panel.rst
```
