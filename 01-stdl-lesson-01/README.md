# STDL Lesson 01

Это минимальный учебный пример для `Renga Style Template Scripting`.

Файлы проекта:

- `parameters.json` описывает параметры стиля
- `main.lua` строит геометрию объекта по этим параметрам
- `metodichka.md` содержит пошаговое объяснение

Идея примера:

- сделать самый простой параметрический объект
- построить 3D-геометрию через `CreateBlock`
- построить простое 2D-отображение сверху через `CreateRectangle2D`

## Что уже проверено

Этот проект проверен вашим локальным builder:

```text
RengaSTDLSDK\RstBuilder\RstBuilder.exe
```

Команда проверки:

```powershell
.\RengaSTDLSDK\RstBuilder\RstBuilder.exe .\01-stdl-lesson-01\parameters.json .\01-stdl-lesson-01\main.lua -s 1.0
```

## Что изучать в этом примере

1. `metadata` в JSON
2. `styleParameters`
3. `Style.GetParameterValues()`
4. `ModelGeometry()`
5. `CreateBlock()`
6. `Style.SetDetailedGeometry()`
7. `Style.SetSymbolicGeometry()`

## Как собрать

Откройте PowerShell в папке:

```text
корень проекта `MyRengaStyle`
```

Соберите `RST`:

```powershell
.\RengaSTDLSDK\RstBuilder\RstBuilder.exe .\01-stdl-lesson-01\parameters.json .\01-stdl-lesson-01\main.lua -s 1.0 -o .\01-stdl-lesson-01\tutorial-box.rst
```

Если хотите только проверить входные файлы без создания `RST`:

```powershell
.\RengaSTDLSDK\RstBuilder\RstBuilder.exe .\01-stdl-lesson-01\parameters.json .\01-stdl-lesson-01\main.lua -s 1.0
```

## Как отлаживать

`print()` пишет сообщения в лог Renga:

```text
%LOCALAPPDATA%\Renga Software\Renga\AecApp.log
```

## Что делать дальше

После того как этот урок станет понятен, переходите к:

- `02-lcd_panel` как к следующему очень простому параметрическому объекту
- или к `metodichka.md`, если хотите подробно разобрать этот пример строка за строкой
