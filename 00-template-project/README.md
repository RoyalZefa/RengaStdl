# 00-template-project

Это стартовая заготовка для нового STDL-проекта.

Что внутри:

- `parameters.json` - минимальный набор параметров
- `main.lua` - минимальная рабочая геометрия
- `build.ps1` - сборка шаблона

## Как использовать

1. Скопируйте папку `00-template-project`
2. Переименуйте копию под свой новый объект
3. Измените `metadata.defaultName`, `description`, `author`
4. Переименуйте и добавьте свои параметры
5. Переделайте `main.lua` под нужную геометрию
6. Соберите `RST`

## Команда сборки

Из корня проекта:

```powershell
.\RengaSTDLSDK\RstBuilder\RstBuilder.exe .\00-template-project\parameters.json .\00-template-project\main.lua -s 1.0 -o .\00-template-project\new-style-template.rst
```

## Для чего этот шаблон хорош

Эта заготовка полезна, когда вы хотите:

- быстро начать новый объект
- не вспоминать каждый раз минимальную структуру JSON
- не вспоминать базовый каркас `main.lua`
- не собирать проект с нуля вручную
