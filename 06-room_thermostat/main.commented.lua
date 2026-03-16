--[[
Подробный разбор файла `main.lua` проекта `06-room_thermostat`.

Этот проект специально стоит после уже разобранных примеров:
- здесь используются знакомые паттерны;
- логика уже не сверхминимальная;
- но проект еще достаточно компактный, чтобы разобрать его целиком.

Важно:
- это учебная версия файла;
- рабочая сборка использует обычный `main.lua`;
- комментарии здесь специально подробные, чтобы вы могли читать файл как конспект.
]]

-- Как читать этот файл:
-- `Типовой паттерн STDL из документации Renga`:
-- чтение параметров, `SetVisible(...)`, создание детальной и условной геометрии,
-- применение `Placement3D(...)` и назначение порта через `Style.GetPort(...)`.
-- `Наша логика проекта`:
-- прямоугольный корпус термостата, круглый регулятор, необязательный экран
-- и один управляющий порт на задней стороне.
-- В собственных проектах вы обычно повторяете каркас STDL,
-- но меняете форму, параметры и смысл подключений.

-- Получаем все значения параметров из `parameters.json`.
-- После этого можно читать параметры по группам:
-- `Dimensions`, `Display` и т.д.
local parameters = Style.GetParameterValues()

-- Читаем габариты корпуса.
local bodyWidth = parameters.Dimensions.BodyWidth
local bodyHeight = parameters.Dimensions.BodyHeight
local bodyDepth = parameters.Dimensions.BodyDepth

-- Читаем диаметр круглого регулятора.
local dialDiameter = parameters.Dimensions.DialDiameter

-- Проверяем, включен ли экран.
--
-- Параметр `HasScreen` - это `UserEnum`.
-- В JSON он может быть:
-- - `Yes`
-- - `No`
local hasScreen = parameters.Display.HasScreen == "Yes"

-- Делаем интерфейс параметров удобнее.
--
-- Если экран включен, параметр `ScreenHeight` показывается.
-- Если экран выключен, он скрывается как неактуальный.
Style.GetParameter("Display", "ScreenHeight"):SetVisible(hasScreen)

-- Создаем основное тело термостата.
-- Это обычный прямоугольный корпус.
local body = CreateBlock(bodyWidth, bodyDepth, bodyHeight)

-- Создаем круглый регулятор.
--
-- Он строится как короткий цилиндр и смещается на лицевую сторону корпуса.
local dial = CreateRightCircularCylinder(dialDiameter / 2, 6)
    :Shift(0, bodyDepth / 2, 0)

-- По умолчанию итоговая геометрия состоит из корпуса и регулятора.
local solid = Unite({body, dial})

-- Если экран включен, достраиваем его как отдельный прямоугольный элемент.
if hasScreen then
    -- Экран делаем уже корпуса и очень тонким по глубине.
    local screen = CreateBlock(bodyWidth * 0.45, 2, parameters.Display.ScreenHeight)
        :Shift(0, bodyDepth / 2, bodyHeight * 0.2)

    -- Объединяем экран с уже существующей геометрией.
    solid = Unite({solid, screen})
end

-- Создаем контейнер для детальной 3D-геометрии.
local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

-- Функция строит 2D-символ термостата.
--
-- В нем:
-- - внешний прямоугольник корпуса
-- - круг регулятора
-- - при необходимости прямоугольник экрана
local function createSymbol()
    local geometry = GeometrySet2D()

    -- Контур корпуса на фронтальном виде.
    local contour = CreateRectangle2D(Point2D(0, 0), 0, bodyWidth, bodyHeight)

    -- Круг регулятора.
    local dial = CreateCircle2D(Point2D(0, -bodyHeight * 0.1), dialDiameter / 2)

    geometry:AddCurve(contour)
    geometry:AddCurve(dial)

    -- Если экран есть, добавляем его и заливаем.
    if hasScreen then
        local screen = CreateRectangle2D(
            Point2D(0, bodyHeight * 0.22),
            0,
            bodyWidth * 0.45,
            parameters.Display.ScreenHeight
        )
        geometry:AddCurve(screen)
        geometry:AddMaterialColorSolidArea(FillArea(screen))
    end

    return geometry
end

-- Создаем компактный символ стиля.
local symbolGeometry = ModelGeometry()
symbolGeometry:AddGeometrySet2D(createSymbol())
Style.SetSymbolGeometry(symbolGeometry)

-- Создаем условную геометрию объекта в модели.
local symbolicGeometry = ModelGeometry()

-- Размещаем 2D-символ на лицевой стороне корпуса.
local frontPlacement = Placement3D(
    Point3D(0, bodyDepth / 2, 0),
    Vector3D(0, 1, 0),
    Vector3D(1, 0, 0)
)
symbolicGeometry:AddGeometrySet2D(createSymbol(), frontPlacement)
Style.SetSymbolicGeometry(symbolicGeometry)

-- Получаем электрический порт линии управления.
local controlPort = Style.GetPort("ControlLine")

-- Размещаем его на задней стороне корпуса.
--
-- Это демонстрирует базовый прием работы с электрическим портом:
-- 1. получить порт по имени;
-- 2. задать ему Placement3D.
controlPort:SetPlacement(Placement3D(
    Point3D(0, -bodyDepth / 2, 0),
    Vector3D(0, -1, 0),
    Vector3D(1, 0, 0)
))
