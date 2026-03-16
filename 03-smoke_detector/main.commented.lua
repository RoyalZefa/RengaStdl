--[[
Подробный построчный разбор файла `main.lua` проекта `smoke_detector`.

Важно:
- этот файл предназначен только для обучения;
- рабочая сборка по-прежнему использует обычный `main.lua`;
- комментарии здесь специально подробные, чтобы код можно было читать как учебный конспект.
]]

-- Как читать этот файл:
-- `Типовой паттерн STDL из документации Renga`:
-- получение параметров, `SetVisible(...)`, создание 3D-геометрии, 2D-символов,
-- использование `ModelGeometry()`, `Placement3D(...)` и работа с портами через `Style.GetPort(...)`.
-- `Наша логика проекта`:
-- цилиндрический корпус датчика, основание, индикатор, выбор варианта монтажа
-- и конкретная схема расположения двух электрических клемм.
-- Ниже полезно мысленно отделять `инструменты STDL` от `идеи модели датчика`.

-- Получаем все значения параметров, описанных в `parameters.json`.
-- После этого у нас есть объект `parameters`, внутри которого лежат группы:
-- `General`, `Dimensions`, `Mounting`, `Indicator`, `Electric`.
local parameters = Style.GetParameterValues()

-- Читаем размеры корпуса датчика.
-- Все эти значения объявлены в JSON в группе `Dimensions`.
local bodyDiameter = parameters.Dimensions.BodyDiameter
local bodyHeight = parameters.Dimensions.BodyHeight
local baseDiameter = parameters.Dimensions.BaseDiameter
local baseHeight = parameters.Dimensions.BaseHeight
local cableLength = parameters.Dimensions.CableLength

-- Читаем режим монтажа.
-- Он может быть `Ceiling` или `Wall`.
local mountType = parameters.Mounting.MountType

-- Читаем режим индикатора.
-- Он может быть:
-- `BuiltIn` - встроенный индикатор
-- `Remote` - выносной индикатор
local indicatorMode = parameters.Indicator.IndicatorMode

-- Читаем настройки электрических портов.
local terminalOffset = parameters.Electric.TerminalOffset
local portLayout = parameters.Electric.PortLayout

-- Вычисляем радиусы, потому что цилиндры в STDL создаются по радиусу, а не по диаметру.
local bodyRadius = bodyDiameter / 2
local baseRadius = baseDiameter / 2
local indicatorRadius = parameters.Indicator.IndicatorDiameter / 2

-- Делаем два логических флага.
-- Они упрощают последующий код:
-- вместо постоянных сравнений строк можно использовать понятные булевы значения.
local isCeilingMount = mountType == "Ceiling"
local isBuiltInIndicator = indicatorMode == "BuiltIn"

-- Управляем видимостью параметров монтажа.
--
-- Если датчик потолочный:
-- - показываем `CeilingOffset`
-- - скрываем `WallOffset`
--
-- Если датчик настенный:
-- - наоборот
Style.GetParameter("Mounting", "CeilingOffset"):SetVisible(isCeilingMount)
Style.GetParameter("Mounting", "WallOffset"):SetVisible(not isCeilingMount)

-- Управляем видимостью параметров индикатора.
--
-- Если индикатор встроенный:
-- - нужен его диаметр
-- - длина кабеля выносного индикатора не нужна
--
-- Если индикатор выносной:
-- - наоборот
Style.GetParameter("Indicator", "IndicatorDiameter"):SetVisible(isBuiltInIndicator)
Style.GetParameter("Indicator", "RemoteIndicatorCable"):SetVisible(not isBuiltInIndicator)

-- Выбираем актуальный отступ монтажа.
--
-- Если монтаж потолочный, берем `CeilingOffset`.
-- Если настенный, берем `WallOffset`.
local mountOffset = isCeilingMount and parameters.Mounting.CeilingOffset or parameters.Mounting.WallOffset

-- Создаем монтажное основание датчика.
--
-- `CreateRightCircularCylinder(radius, height)` строит цилиндр.
-- Здесь это нижняя "пятка", которой датчик крепится к поверхности.
local baseSolid = CreateRightCircularCylinder(baseRadius, baseHeight)

-- Создаем основной корпус датчика.
-- Сдвигаем его вверх на высоту основания, чтобы он стоял поверх базы.
local bodySolid = CreateRightCircularCylinder(bodyRadius, bodyHeight)
    :Shift(0, 0, baseHeight)

-- Создаем маленький цилиндр-индикатор.
--
-- Он расположен не по центру, а немного смещен по X,
-- чтобы был заметен как отдельный элемент.
--
-- По Z он ставится почти на верхней плоскости корпуса.
local indicatorSolid = CreateRightCircularCylinder(indicatorRadius, 2)
    :Shift(bodyRadius * 0.35, 0, baseHeight + bodyHeight - 2)

-- Собираем итоговую геометрию.
--
-- Если индикатор встроенный, добавляем его в модель.
-- Если индикатор выносной, строим только основание и корпус.
local solid = isBuiltInIndicator
    and Unite({baseSolid, bodySolid, indicatorSolid})
    or Unite({baseSolid, bodySolid})

-- Сдвигаем всю модель по Z с учетом монтажного отступа.
--
-- Это демонстрирует важный прием:
-- параметры можно использовать не только для размеров, но и для общего положения объекта.
solid = solid:Shift(0, 0, -mountOffset)

-- Создаем контейнер для детальной 3D-геометрии.
local detailedGeometry = ModelGeometry()

-- Добавляем итоговое твердое тело.
detailedGeometry:AddSolid(solid)

-- Передаем детальную геометрию в Renga.
Style.SetDetailedGeometry(detailedGeometry)

-- Функция строит 2D-символ датчика.
--
-- Здесь символ максимально простой, но понятный:
-- - внешняя окружность
-- - внутренняя окружность
-- - вертикальная линия
-- - горизонтальная линия
--
-- Такой знак легко узнается как точечный датчик на плане.
local function createDetectorSymbol()
    local geometry = GeometrySet2D()

    -- Внешняя окружность соответствует диаметру основания.
    local outer = CreateCircle2D(Point2D(0, 0), baseRadius)

    -- Внутренняя окружность меньше и подчеркивает корпус датчика.
    local inner = CreateCircle2D(Point2D(0, 0), bodyRadius * 0.65)

    -- Добавляем обе окружности как кривые.
    geometry:AddCurve(outer)
    geometry:AddCurve(inner)

    -- Добавляем заливку по внешнему контуру.
    geometry:AddMaterialColorSolidArea(FillArea(outer))

    -- Добавляем горизонтальную осевую линию.
    geometry:AddCurve(CreateLineSegment2D(Point2D(-bodyRadius * 0.45, 0), Point2D(bodyRadius * 0.45, 0)))

    -- Добавляем вертикальную осевую линию.
    geometry:AddCurve(CreateLineSegment2D(Point2D(0, -bodyRadius * 0.45), Point2D(0, bodyRadius * 0.45)))

    return geometry
end

-- Создаем отдельную компактную геометрию символа.
-- Она может использоваться Renga как символ стиля.
local symbolGeometry = ModelGeometry()
symbolGeometry:AddGeometrySet2D(createDetectorSymbol())
Style.SetSymbolGeometry(symbolGeometry)

-- Создаем условную геометрию объекта для вида в модели/на плане.
local symbolicGeometry = ModelGeometry()

-- Размещаем символ на верхней точке корпуса с учетом монтажного смещения.
local symbolPlacement = Placement3D(
    Point3D(0, 0, baseHeight + bodyHeight - mountOffset),
    Vector3D(0, 0, 1),
    Vector3D(1, 0, 0)
)

-- Добавляем символ в условную геометрию.
symbolicGeometry:AddGeometrySet2D(createDetectorSymbol(), symbolPlacement)

-- Передаем условную геометрию в Renga.
Style.SetSymbolicGeometry(symbolicGeometry)

-- Вспомогательная функция сдвигает Placement3D вдоль его локальной оси Z.
--
-- Это тот же прием, который мы уже использовали раньше:
-- placement указывает точку основания подключения,
-- а сдвиг по локальной оси позволяет вынести порт на конец "кабельного вывода".
local function shiftPlacementByZ(placement, shift)
    local vector = placement:GetZAxisDirection()
    return placement:Clone():Shift(
        vector:GetX() * shift,
        vector:GetY() * shift,
        vector:GetZ() * shift
    )
end

-- Высота размещения клемм.
-- Мы ставим их примерно на уровне монтажного основания.
local portZ = baseHeight / 2 - mountOffset

-- Первая клемма всегда уходит влево от центра.
local terminalX1 = -terminalOffset

-- Вторая клемма зависит от режима расположения:
-- - `Opposite` -> по другую сторону центра
-- - `Near` -> рядом, то есть у центра
local terminalX2 = portLayout == "Opposite" and terminalOffset or 0

-- Формируем Placement3D для порта питания.
--
-- Точка:
-- - смещена по X на terminalX1
-- - по Y стоит в центре
-- - по Z находится на высоте основания
--
-- Вектор Z смотрит вниз, потому что мы интерпретируем подключение как выходящее к монтажной поверхности.
local powerPlacement = Placement3D(
    Point3D(terminalX1, 0, portZ),
    Vector3D(0, 0, -1),
    Vector3D(1, 0, 0)
)

-- Формируем Placement3D для шлейфа сигнализации.
local alarmPlacement = Placement3D(
    Point3D(terminalX2, 0, portZ),
    Vector3D(0, 0, -1),
    Vector3D(1, 0, 0)
)

-- Получаем электрический порт питания по имени из JSON.
local powerSupplyPort = Style.GetPort("PowerSupply")

-- Ставим его на конце условного кабельного вывода.
powerSupplyPort:SetPlacement(shiftPlacementByZ(powerPlacement, cableLength))

-- Получаем порт шлейфа сигнализации.
local alarmLoopPort = Style.GetPort("AlarmLoop")

-- Тоже выносим его по локальной оси на длину кабеля.
alarmLoopPort:SetPlacement(shiftPlacementByZ(alarmPlacement, cableLength))
