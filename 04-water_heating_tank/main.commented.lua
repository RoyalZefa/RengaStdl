--[[
Подробный разбор учебного STDL-скрипта "Нагревательный бак для воды".

Важно:
- этот файл создан только для обучения;
- рабочая сборка по-прежнему использует `main.lua`;
- комментарии здесь максимально подробные, чтобы можно было читать код сверху вниз как методичку.
]]

-- Как читать этот файл:
-- `Типовой паттерн STDL из документации Renga`:
-- чтение параметров, создание `ModelGeometry()`, использование `Placement3D(...)`,
-- настройка 2D-символов и портов через API стиля.
-- `Наша логика проекта`:
-- цилиндрический бак, уровни горячей и холодной воды, боковые патрубки,
-- электрический вывод и выбранная нами условная символика.
-- Сам API и приемы типовые, а форма бака и набор параметров относятся уже к нашему примеру.

-- Получаем все значения параметров из `parameters.json`.
-- После этого у нас появляется объект `parameters`, внутри которого есть группы:
-- `Dimensions`, `WaterConnections`, `Electric`.
local parameters = Style.GetParameterValues()

-- Читаем основные размеры бака.
-- Эти значения были объявлены в JSON внутри группы `Dimensions`.
local tankDiameter = parameters.Dimensions.TankDiameter
local tankHeight = parameters.Dimensions.TankHeight
local nozzleLength = parameters.Dimensions.NozzleLength
local coldWaterLevel = parameters.Dimensions.ColdWaterLevel
local hotWaterLevel = parameters.Dimensions.HotWaterLevel

-- Радиус нужен чаще, чем диаметр, поэтому считаем его сразу один раз.
-- Это типичный прием: заранее вычислить удобные вспомогательные значения.
local tankRadius = tankDiameter / 2

-- Читаем пользовательские настройки расположения портов.
-- `PortsSide` задает сторону трубных патрубков.
-- `CableSide` задает сторону электрического вывода.
local portsSide = parameters.WaterConnections.PortsSide
local cableSide = parameters.Electric.CableSide

-- Превращаем пользовательский выбор "left/right" в удобные коэффициенты.
-- Если патрубки справа, направление по X = 1.
-- Если слева, направление по X = -1.
--
-- Зачем это нужно:
-- вместо множества `if` в геометрии мы можем просто умножать координату на 1 или -1.
local nozzleDirection = portsSide == "right" and 1 or -1
local cableDirection = cableSide == "right" and 1 or -1

-- Функция строит Placement3D для трубного патрубка по заданной высоте.
--
-- Что такое Placement3D:
-- это положение объекта в пространстве:
-- 1. точка вставки;
-- 2. направление локальной оси Z;
-- 3. направление локальной оси X.
--
-- Для STDL это очень важная сущность.
-- Именно через Placement3D мы говорим, где находится деталь и в какую сторону она направлена.
local function getPipePlacement(zLevel)
    return Placement3D(
        -- Точка патрубка ставится на боковой поверхности цилиндра.
        -- По X мы уходим на радиус бака вправо или влево.
        -- По Y оставляем 0, потому что патрубки торчат из боковой поверхности в плоскости XZ.
        -- По Z опускаем уровень на половину высоты бака, так как тело бака будет
        -- центрироваться относительно нуля и уходить вниз/вверх от середины.
        Point3D(nozzleDirection * tankRadius, 0, zLevel - tankHeight / 2),

        -- Локальная ось Z указывает направление порта.
        -- Если патрубок справа, он "смотрит" вправо.
        -- Если слева, он "смотрит" влево.
        Vector3D(nozzleDirection, 0, 0),

        -- Локальная ось X задает дополнительную ориентацию.
        -- Здесь берем вертикаль, чтобы матрица размещения была определена однозначно.
        Vector3D(0, 0, 1)
    )
end

-- Создаем положение нижнего патрубка холодной воды.
-- Высота берется из параметра `ColdWaterLevel`.
local coldWaterPlacement = getPipePlacement(coldWaterLevel)

-- Создаем положение верхнего патрубка горячей воды.
-- Высота берется из параметра `HotWaterLevel`.
local hotWaterPlacement = getPipePlacement(hotWaterLevel)

-- Создаем размещение электрического порта.
--
-- Он тоже выходит с боковой поверхности цилиндра, но его положение настраивается
-- отдельными параметрами `CableSide` и `CableHeight`.
local powerPlacement = Placement3D(
    Point3D(cableDirection * tankRadius, 0, parameters.Electric.CableHeight - tankHeight / 2),
    Vector3D(cableDirection, 0, 0),
    Vector3D(0, 0, 1)
)

-- Эта функция управляет видимостью параметров соединения в интерфейсе стиля.
--
-- Идея:
-- если пользователь выбрал резьбовое соединение, ему нужен `ThreadSize`,
-- а `NominalDiameter` становится лишним.
-- Если соединение не резьбовое, наоборот.
--
-- Это не влияет на геометрию напрямую, но делает интерфейс намного удобнее.
local function hideIrrelevantPipePortParams(groupName)
    local isThread =
        Style.GetParameter(groupName, "ConnectionType"):GetValue() ==
            PipeConnectorType.Thread

    Style.GetParameter(groupName, "ThreadSize"):SetVisible(isThread)
    Style.GetParameter(groupName, "NominalDiameter"):SetVisible(not isThread)
end

-- Применяем логику скрытия параметров к группе водяных подключений.
hideIrrelevantPipePortParams("WaterConnections")

-- Создаем цилиндрическое тело бака.
--
-- `CreateRightCircularCylinder(radius, height)` создает цилиндр.
-- Затем мы сдвигаем его вниз на половину высоты,
-- чтобы середина бака оказалась в нулевой отметке локальной системы координат.
--
-- Это удобно, потому что уровни патрубков потом проще считать относительно середины.
local tankBody = CreateRightCircularCylinder(tankRadius, tankHeight)
    :Shift(0, 0, -tankHeight / 2)

-- Радиус патрубка берется из номинального диаметра водяного подключения.
-- Здесь мы используем значение диаметра как геометрическую основу для цилиндра-патрубка.
local nozzleRadius = parameters.WaterConnections.NominalDiameter / 2

-- Создаем прототип патрубка.
--
-- Почему это удобно:
-- у нас два одинаковых патрубка, поэтому мы создаем один базовый цилиндр,
-- а потом клонируем его и ставим в разные места.
local nozzlePrototype = CreateRightCircularCylinder(nozzleRadius, nozzleLength)

-- Создаем патрубок холодной воды.
-- Сначала делаем копию прототипа, затем применяем матрицу размещения.
local coldNozzle = nozzlePrototype:Clone():Transform(coldWaterPlacement:GetMatrix())

-- Создаем патрубок горячей воды таким же способом.
local hotNozzle = nozzlePrototype:Clone():Transform(hotWaterPlacement:GetMatrix())

-- Объединяем геометрию бака и двух патрубков в одно тело.
-- Это уже итоговая 3D-модель объекта.
local solid = Unite({tankBody, coldNozzle, hotNozzle})

-- Создаем контейнер для детальной геометрии.
-- В Renga это основная 3D-геометрия, которая будет видна как модель.
local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

-- Функция строит 2D-символ бака для вида сверху.
--
-- Здесь мы намеренно делаем символ простым:
-- круг + вертикальная линия + короткая горизонтальная линия.
--
-- Такой символ хорошо показывает:
-- 1. круглую форму бака;
-- 2. условное направление/центр.
local function createTopSymbol()
    local geometry = GeometrySet2D()

    -- Контур бака на плане.
    local contour = CreateCircle2D(Point2D(0, 0), tankRadius)
    geometry:AddCurve(contour)

    -- Добавляем заливку по контуру.
    -- Это делает символ более наглядным.
    geometry:AddMaterialColorSolidArea(FillArea(contour))

    -- Вертикальная линия внутри символа.
    geometry:AddCurve(CreateLineSegment2D(Point2D(0, -tankRadius * 0.6), Point2D(0, tankRadius * 0.6)))

    -- Короткая горизонтальная линия в центре.
    geometry:AddCurve(CreateLineSegment2D(Point2D(-tankRadius * 0.25, 0), Point2D(tankRadius * 0.25, 0)))

    return geometry
end

-- Создаем отдельную "иконку" стиля.
-- Это компактное символическое представление, которое может использоваться в интерфейсе.
local symbolGeometry = ModelGeometry()
symbolGeometry:AddGeometrySet2D(createTopSymbol())
Style.SetSymbolGeometry(symbolGeometry)

-- Создаем условную геометрию объекта для модели/плана.
local symbolicGeometry = ModelGeometry()

-- Размещаем символ на верхней точке бака.
-- Так 2D-символ будет лежать на верхней плоскости цилиндра.
local topPlacement = Placement3D(
    Point3D(0, 0, tankHeight / 2),
    Vector3D(0, 0, 1),
    Vector3D(1, 0, 0)
)

symbolicGeometry:AddGeometrySet2D(createTopSymbol(), topPlacement)
Style.SetSymbolicGeometry(symbolicGeometry)

-- Вспомогательная функция сдвигает Placement3D вдоль его локальной оси Z.
--
-- Зачем это нужно:
-- Placement патрубка задает основание цилиндра у корпуса,
-- а порт подключения нужно поставить на свободный конец патрубка.
local function shiftPlacementByZ(placement, shift)
    local vector = placement:GetZAxisDirection()
    return placement:Clone():Shift(
        vector:GetX() * shift,
        vector:GetY() * shift,
        vector:GetZ() * shift
    )
end

-- Функция задает параметры трубного порта.
--
-- Если соединение резьбовое, передаем `ThreadSize`.
-- Иначе передаем обычный `NominalDiameter`.
local function setPipeParameters(port, portParameters)
    local connectionType = portParameters.ConnectionType
    if connectionType == PipeConnectorType.Thread then
        port:SetPipeParameters(connectionType, portParameters.ThreadSize)
    else
        port:SetPipeParameters(connectionType, portParameters.NominalDiameter)
    end
end

-- Получаем порт холодной воды по имени из JSON.
local coldWaterPort = Style.GetPort("ColdWaterInlet")

-- Ставим порт не у основания патрубка, а на его торце.
-- Для этого сдвигаем placement вдоль локальной оси Z на длину патрубка.
coldWaterPort:SetPlacement(shiftPlacementByZ(coldWaterPlacement, nozzleLength))

-- Назначаем порту тип соединения и размер.
setPipeParameters(coldWaterPort, parameters.WaterConnections)

-- Аналогично настраиваем порт горячей воды.
local hotWaterPort = Style.GetPort("HotWaterOutlet")
hotWaterPort:SetPlacement(shiftPlacementByZ(hotWaterPlacement, nozzleLength))
setPipeParameters(hotWaterPort, parameters.WaterConnections)

-- Электрический порт проще:
-- ему не нужны трубные параметры, нужно только правильное положение в пространстве.
local powerSupplyPort = Style.GetPort("PowerSupply")
powerSupplyPort:SetPlacement(powerPlacement)
