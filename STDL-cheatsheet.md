# STDL Cheatsheet

Короткая шпаргалка по самым важным конструкциям `Renga Style Template Scripting`.

## Базовый цикл

Почти любой шаблон строится по одной схеме:

1. получить параметры через `Style.GetParameterValues()`
2. вычислить удобные локальные переменные
3. построить 3D-геометрию
4. построить 2D-символику
5. настроить порты
6. при необходимости скрыть лишние параметры через `SetVisible()`

## Что где хранится

- `parameters.json` или `configuration.json`
  Здесь описываются параметры, группы параметров и порты.

- `main.lua` или `run.lua`
  Здесь описывается логика: как по параметрам строится объект.

## Частые функции

- `Style.GetParameterValues()`
  Получить все значения параметров.

- `Style.GetParameter(group, param)`
  Получить конкретный параметр для управления видимостью или чтения значения.

- `Style.GetPort(name)`
  Получить порт по имени из JSON.

- `ModelGeometry()`
  Контейнер для 3D- или 2D-геометрии.

- `GeometrySet2D()`
  Контейнер для 2D-кривых и заливки.

- `Style.SetDetailedGeometry(...)`
  Передать основную 3D-геометрию объекта.

- `Style.SetSymbolGeometry(...)`
  Передать компактный символ стиля.

- `Style.SetSymbolicGeometry(...)`
  Передать условную геометрию объекта.

## Частые 3D-примитивы

- `CreateBlock(width, depth, height)`
  Прямоугольный блок.

- `CreateRightCircularCylinder(radius, height)`
  Цилиндр.

- `Extrude(contour, params, placement)`
  Выдавливание профиля.

- `Unite({...})`
  Объединение тел.

## Частые 2D-примитивы

- `CreateRectangle2D(center, angle, width, height)`
- `CreateCircle2D(center, radius)`
- `CreateLineSegment2D(p0, p1)`
- `CreatePolyline2D(points)`
- `CreateCompositeCurve2D({...})`

## Placement3D

`Placement3D(point, zAxis, xAxis)` задает:

- точку
- направление локальной оси Z
- направление локальной оси X

Используется для:

- размещения тел
- размещения 2D-символики
- размещения портов

## SetVisible()

Типовой прием:

```lua
local isModeA = parameters.Group.Mode == "A"
Style.GetParameter("Group", "ParamA"):SetVisible(isModeA)
Style.GetParameter("Group", "ParamB"):SetVisible(not isModeA)
```

Используется, когда в интерфейсе нужно показывать только актуальные параметры.

## UserEnum

В JSON:

```json
{
  "name": "MountType",
  "type": "UserEnum",
  "default": "Wall",
  "items": [
    { "key": "Wall", "text": "Настенный" },
    { "key": "Table", "text": "Настольный" }
  ]
}
```

В Lua:

```lua
local isTable = parameters.Mounting.MountType == "Table"
```

## Трубные порты

Типовой шаблон:

```lua
local port = Style.GetPort("PipePort")
port:SetPlacement(placement)
port:SetPipeParameters(connectionType, diameter)
```

## Электрические порты

Типовой шаблон:

```lua
local port = Style.GetPort("PowerSupply")
port:SetPlacement(placement)
```

## Что смотреть в примерах

- `01-stdl-lesson-01`
  Самая база.

- `02-lcd_panel`
  Первый простой параметрический объект.

- `03-smoke_detector`
  Простой объект с `SetVisible()` и электрическими портами.

- `04-water_heating_tank`
  Средний инженерный пример.

- `05-official_primer`
  Продвинутый официальный пример.

- `06-room_thermostat`
  Первый самостоятельный проект как следующий шаг.
