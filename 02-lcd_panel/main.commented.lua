--[[
Подробный разбор файла `main.lua` проекта `lcd_panel`.

Это учебная версия файла.

Важно:
- рабочая сборка по-прежнему использует `main.lua`;
- этот файл нужен только для чтения и обучения;
- комментарии написаны подробно, чтобы код можно было читать как пошаговую методичку.

Дополнительно в этом файле я отмечаю два типа кода:

1. "Паттерн из документации / samples Renga"
   Это не обязательно буквальная копия, но это типовой прием,
   который постоянно встречается в официальных примерах STDL:
   - `Style.GetParameterValues()`
   - `ModelGeometry()`
   - `Style.SetDetailedGeometry(...)`
   - `GeometrySet2D()`
   - `Style.SetSymbolGeometry(...)`
   - `Style.SetSymbolicGeometry(...)`
   - `Style.GetParameter(...):SetVisible(...)`
   - `Placement3D(...)`

2. "Наша логика проекта"
   Это уже не готовый шаблон из документации, а то,
   как именно мы применили стандартные инструменты STDL к LCD-панели:
   - какие параметры выбрали;
   - как именно считаем размеры подставки;
   - как именно рисуем экран;
   - где именно размещаем символ на лицевой поверхности.
]]

-- Паттерн из документации / samples Renga:
-- почти любой STDL-скрипт начинается с получения параметров через Style.GetParameterValues().
--
-- Наша логика проекта:
-- дальше мы будем использовать эти параметры именно для LCD-панели,
-- а не для вентиляции, труб, нагревателя и т.д.
-- Получаем все значения параметров из `parameters.json`.
-- После этого у нас появляется объект `parameters`,
-- внутри которого есть группы `Dimensions` и `Mounting`.
local parameters = Style.GetParameterValues()

-- Наша логика проекта:
-- набор этих параметров полностью придуман для учебной LCD-панели.
-- В официальной документации нет "обязательных" имен `PanelWidth`, `PanelHeight` и т.п.
-- Это уже наша модель предметной области.
-- Читаем размеры панели.
-- Эти параметры были объявлены в JSON в группе `Dimensions`.
local panelWidth = parameters.Dimensions.PanelWidth
local panelHeight = parameters.Dimensions.PanelHeight
local panelDepth = parameters.Dimensions.PanelDepth
local screenMargin = parameters.Dimensions.ScreenMargin

-- Наша логика проекта:
-- сам флаг `isTableMount` - это наша прикладная логика для панели.
-- Но прием "получить enum из JSON и превратить его в удобный boolean"
-- очень типичен для STDL и постоянно используется в реальных шаблонах.
-- Проверяем, выбран ли настольный монтаж.
--
-- `MountType` в JSON - это UserEnum.
-- Он может быть:
-- - `Wall`
-- - `Table`
--
-- Здесь мы превращаем строковое значение в удобный логический флаг.
local isTableMount = parameters.Mounting.MountType == "Table"

-- Паттерн из документации / samples Renga:
-- `Style.GetParameter(...):SetVisible(...)` - типовой прием для динамического интерфейса параметров.
--
-- Наша логика проекта:
-- скрываем именно `StandDepth`, потому что в настенном варианте подставка не нужна.
-- Управляем видимостью параметра `StandDepth`.
--
-- Если монтаж настольный, глубина подставки нужна и показывается.
-- Если монтаж настенный, она не нужна и скрывается.
Style.GetParameter("Mounting", "StandDepth"):SetVisible(isTableMount)

-- Паттерн из документации / samples Renga:
-- построение простого тела через `CreateBlock(...)` - один из самых базовых приемов STDL.
--
-- Наша логика проекта:
-- мы используем его именно как корпус LCD-панели.
-- Создаем основное тело панели.
--
-- `CreateBlock(width, depth, height)` создает прямоугольный параллелепипед.
-- Это самая простая 3D-геометрия в STDL.
local body = CreateBlock(panelWidth, panelDepth, panelHeight)

-- Наша логика проекта:
-- в качестве стартового состояния берем только корпус панели.
-- Потом, если монтаж настольный, расширяем модель подставкой.
-- По умолчанию итоговая геометрия равна только корпусу панели.
local solid = body

-- Наша логика проекта:
-- сам факт наличия подставки только в настольном режиме - это наша учебная идея.
-- В документации есть похожий общий прием "строить геометрию условно по параметрам",
-- но конкретно эти размеры и эта форма придуманы нами.
-- Если выбран настольный монтаж, создаем подставку.
if isTableMount then
    -- Ширина подставки берется как доля ширины панели.
    local standWidth = panelWidth * 0.35

    -- Высота подставки берется как доля высоты панели.
    local standHeight = panelHeight * 0.08

    -- Глубину подставки пользователь задает параметром `StandDepth`.
    local standDepth = parameters.Mounting.StandDepth

    -- Наша логика проекта:
    -- расположение подставки выбрано вручную так,
    -- чтобы она выступала вперед и подпирала нижнюю часть панели.
    -- Строим прямоугольную подставку.
    -- Потом смещаем ее:
    -- - по Y вперед от панели
    -- - по Z вниз к нижней части корпуса
    local stand = CreateBlock(standWidth, standDepth, standHeight)
        :Shift(0, panelDepth / 2 + standDepth / 2, -panelHeight / 2 + standHeight / 2)

    -- Паттерн из документации / samples Renga:
    -- `Unite(...)` - типовой способ объединить несколько тел в одно.
    --
    -- Наша логика проекта:
    -- объединяем именно корпус и подставку панели.
    -- Объединяем корпус и подставку в одно твердое тело.
    solid = Unite({body, stand})
end

-- Паттерн из документации / samples Renga:
-- контейнер `ModelGeometry()` + `AddSolid(...)` + `Style.SetDetailedGeometry(...)`
-- это стандартный каркас задания детальной геометрии объекта.
-- Создаем контейнер для детальной 3D-геометрии.
local detailedGeometry = ModelGeometry()

-- Добавляем туда итоговое тело панели.
detailedGeometry:AddSolid(solid)

-- Передаем детальную геометрию в Renga.
Style.SetDetailedGeometry(detailedGeometry)

-- Паттерн из документации / samples Renga:
-- выносить построение 2D-символа в отдельную функцию - очень хороший и частый прием.
--
-- Наша логика проекта:
-- символ LCD-панели мы придумали сами:
-- внешний прямоугольник = корпус,
-- внутренний прямоугольник = экран.
-- Функция строит 2D-символ панели.
--
-- Символ очень простой:
-- - внешний прямоугольник панели
-- - внутренний прямоугольник экрана
-- - заливка области экрана
local function createFrontSymbol()
    local geometry = GeometrySet2D()

    -- Паттерн из документации / samples Renga:
    -- `CreateRectangle2D(...)` и добавление кривых в `GeometrySet2D()`
    -- это базовый способ строить 2D-представление.
    --
    -- Наша логика проекта:
    -- мы интерпретируем внешний прямоугольник как рамку LCD-панели.
    -- Внешний контур панели.
    local outer = CreateRectangle2D(Point2D(0, 0), 0, panelWidth, panelHeight)

    -- Наша логика проекта:
    -- экран строится как второй прямоугольник, уменьшенный на двойной `screenMargin`.
    -- Это уже не "официальный шаблон", а наше прикладное решение.
    -- Внутренний контур экрана.
    -- Его размеры меньше на двойной отступ `ScreenMargin`.
    local screen = CreateRectangle2D(
        Point2D(0, 0),
        0,
        panelWidth - screenMargin * 2,
        panelHeight - screenMargin * 2
    )

    -- Добавляем оба прямоугольника в геометрию.
    geometry:AddCurve(outer)
    geometry:AddCurve(screen)

    -- Паттерн из документации / samples Renga:
    -- `AddMaterialColorSolidArea(FillArea(...))` - типовой прием для 2D-заливки.
    --
    -- Наша логика проекта:
    -- заливаем именно область экрана, чтобы он визуально отличался от рамки.
    -- Заливаем внутреннюю область экрана.
    geometry:AddMaterialColorSolidArea(FillArea(screen))

    return geometry
end

-- Паттерн из документации / samples Renga:
-- отдельный `Style.SetSymbolGeometry(...)` часто используется для "иконки" стиля.
-- Создаем компактный символ стиля.
local symbolGeometry = ModelGeometry()
symbolGeometry:AddGeometrySet2D(createFrontSymbol())
Style.SetSymbolGeometry(symbolGeometry)

-- Паттерн из документации / samples Renga:
-- `ModelGeometry()` + `AddGeometrySet2D(...)` + `Style.SetSymbolicGeometry(...)`
-- это стандартный способ задать условную геометрию.
-- Создаем условную геометрию панели.
local symbolicGeometry = ModelGeometry()

-- Паттерн из документации / samples Renga:
-- `Placement3D(...)` используется для размещения 2D-символа в 3D-пространстве.
--
-- Наша логика проекта:
-- мы размещаем символ именно на лицевой поверхности панели,
-- то есть спереди по оси Y.
-- Размещаем 2D-символ на лицевой поверхности панели.
--
-- Почему именно так:
-- - точка ставится по центру передней плоскости;
-- - ось Z символа направлена вперед по Y;
-- - ось X совпадает с горизонталью панели.
local frontPlacement = Placement3D(
    Point3D(0, panelDepth / 2, 0),
    Vector3D(0, 1, 0),
    Vector3D(1, 0, 0)
)

-- Паттерн из документации / samples Renga:
-- добавление готового набора 2D-примитивов в symbolic geometry.
-- Добавляем 2D-символ с нужным размещением.
symbolicGeometry:AddGeometrySet2D(createFrontSymbol(), frontPlacement)

-- Передаем условную геометрию в Renga.
Style.SetSymbolicGeometry(symbolicGeometry)
