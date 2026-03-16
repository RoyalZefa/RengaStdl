--[[
Подробный разбор файла `main.lua` из проекта `official_primer`.

Важно:
- это учебная версия файла;
- рабочая сборка по-прежнему использует обычный `main.lua`;
- комментарии написаны подробно, чтобы читать код как методичку прямо сверху вниз.
]]

-- Как читать этот файл:
-- `Типовой паттерн STDL из документации Renga`:
-- `ModelGeometry()`, `Extrude(...)`, `Placement3D(...)`, создание 2D-геометрии,
-- настройка портов и управление видимостью параметров через `SetVisible(...)`.
-- `Логика именно official_primer`:
-- форма корпуса VRF-блока, конкретные группы параметров, схема жидкостных, газовых,
-- дренажных и электрических подключений.
-- Код ниже полезно читать именно в таком разрезе: что можно перенести как шаблон,
-- а что относится только к данному примеру оборудования.

-- Создаем контейнер для детальной 3D-геометрии объекта.
-- Позже сюда будет добавлено твердое тело VRF-блока.
local detailedGeometry = ModelGeometry()

-- Получаем все значения параметров из `parameters.json`.
-- После этого можно обращаться к группам параметров:
-- `Dimensions`, `WaterCoolant`, `GasCoolant`, `Drainage`, `ElectricConnectors` и так далее.
local parameters = Style.GetParameterValues()

-- Читаем основные размеры корпуса.
-- Здесь важно заметить, что имена параметров полностью совпадают с тем, что объявлено в JSON.
local height = parameters.Dimensions.bodyHeight
local width = parameters.Dimensions.bodyWidth
local length = parameters.Dimensions.bodyLength

-- Функция строит 2D-профиль корпуса.
--
-- Логика примера:
-- 1. сначала описывается поперечное сечение блока;
-- 2. потом это сечение выдавливается в 3D через Extrude().
--
-- Такой подход гибче, чем прямой CreateBlock(), потому что можно получить более реалистичную форму.
local function makeProfile()
    local points = {
        Point2D(0, 0),
        Point2D(0, height),
        Point2D(width, height),
        Point2D(width, height / 8),
        Point2D(width / 3, 0),
        Point2D(0, 0)}

    -- Создаем полилинию по точкам.
    local profile = CreatePolyline2D(points)

    -- Скругляем угол после второго сегмента.
    -- Это делает форму корпуса менее "коробочной".
    FilletCornerAfterSegment2D(profile, 2, width / 4)
    return profile
end

-- Задаем локальную систему координат для выдавливания.
-- Placement3D определяет положение и ориентацию будущего твердого тела.
local vrfPlacement = Placement3D(Point3D(0, 0, 0),
                                 Vector3D(-1, 0, 0),
                                 Vector3D(0, -1, 0))

-- Параметры операции выдавливания.
-- Здесь глубина выдавливания равна длине корпуса.
local extrusionParams = ExtrusionParameters(length)

-- Создаем 3D-тело:
-- 1. строим профиль;
-- 2. выдавливаем его;
-- 3. сдвигаем тело, чтобы оно оказалось в удобном месте локальной системы координат.
local vrfSolid = Extrude(makeProfile(), extrusionParams, vrfPlacement)
    :Shift(length / 2, width / 2, 0)

-- Добавляем готовое тело в контейнер детальной геометрии.
detailedGeometry:AddSolid(vrfSolid)

-- Передаем 3D-геометрию в Renga как основную модель объекта.
Style.SetDetailedGeometry(detailedGeometry)

-- Создаем контейнер для условной геометрии.
-- Это та геометрия, которая отображается в упрощенном виде, например на плане.
local symbolicGeometry = ModelGeometry()

-- Прямоугольный контур блока в плане.
local contour = CreateRectangle2D(Point2D(0, 0), 0, length, width)

-- Создаем графический символ внутри прямоугольника.
-- Здесь символ выполнен из дуг и отрезков и напоминает букву S.
local letterS = CreateCompositeCurve2D({
                    CreateArc2DByThreePoints(Point2D(19.4, 23), Point2D(4.2, 30.4), Point2D(-12, 26)),
                    CreateArc2DByThreePoints(Point2D(-12, 26), Point2D(-16.4, 14.2), Point2D(-9, 4.2)),
                    CreateLineSegment2D(Point2D(-9, 4.2), Point2D(9, -4.2)),
                    CreateArc2DByThreePoints(Point2D(9, -4.2), Point2D(16.4, -14.2), Point2D(12, -26)),
                    CreateArc2DByThreePoints(Point2D(12, -26), Point2D(-4.2, -30.4), Point2D(-19.4, -23))})

-- Создаем набор 2D-геометрии.
local geometry = GeometrySet2D()

-- Размещаем 2D-символ на верхней плоскости корпуса.
local geometryPlacement = Placement3D(Point3D(0, 0, height), Vector3D(0, 0, 1), Vector3D(1, 0, 0))

-- Добавляем контур и символ.
geometry:AddCurve(contour):AddCurve(letterS)

-- Добавляем заливку по материалу внутри прямоугольника.
geometry:AddMaterialColorSolidArea(FillArea(contour))

-- Передаем набор 2D-примитивов в условную геометрию объекта.
symbolicGeometry:AddGeometrySet2D(geometry, geometryPlacement)

-- Завершаем настройку условной геометрии.
Style.SetSymbolicGeometry(symbolicGeometry)

-- Дальше начинается логика трубных портов.
-- Сначала считаем несколько вспомогательных величин.
local halfWidth = width / 2
local halfLengthWithIndent50 = length / 2 - 50
local waterPortIntendation = parameters.WaterCoolant.portIndentation
local gasPortIntendation = parameters.GasCoolant.portIndentation
local drainagePortIntendation = parameters.Drainage.portIndentation

-- Начальные точки портов.
-- Пока все в нуле, потом будут пересчитаны в зависимости от стороны подключения.
local waterCoolantOrigin = Point3D(0, 0, 0)
local gasCoolantOrigin = Point3D(0, 0, 0)
local drainageOrigin = Point3D(0, 0, 0)

-- Если подключение жидкостного трубопровода справа, ставим порт справа.
-- Иначе - слева.
if parameters.WaterCoolant.connectionSide == "right" then
    waterCoolantOrigin = Point3D(halfLengthWithIndent50,
                                 halfWidth - waterPortIntendation, 75)
else
    waterCoolantOrigin = Point3D(-halfLengthWithIndent50,
                                  halfWidth - waterPortIntendation, 75)
end

-- Та же логика для газовой линии.
if parameters.GasCoolant.connectionSide == "right" then
    gasCoolantOrigin = Point3D(halfLengthWithIndent50,
                               halfWidth - gasPortIntendation, 50)
else
    gasCoolantOrigin = Point3D(-halfLengthWithIndent50,
                                halfWidth - gasPortIntendation, 50)
end

-- И для дренажа.
if parameters.Drainage.connectionSide == "right" then
    drainageOrigin = Point3D(halfLengthWithIndent50,
                             halfWidth - drainagePortIntendation, 25)
else
    drainageOrigin = Point3D(-halfLengthWithIndent50,
                              halfWidth - drainagePortIntendation, 25)
end

-- Функция возвращает ориентацию порта в зависимости от направления подключения.
--
-- Почему это важно:
-- порт определяется не только точкой, но и тем, куда он "смотрит".
-- Поэтому нужно корректно задать его оси.
local function rotateVectors(name)
    local direction = parameters[name].connectionDirection
    local side = parameters[name].connectionSide

    -- Направления по умолчанию.
    local vectorZ = Vector3D(0, 0, 1)
    local vectorX = Vector3D(1, 0, 0)

    if direction == "side" then
        if side == "right" then
            vectorZ = Vector3D(1, 0, 0)
            vectorX = Vector3D(0, 1, 0)
        else
            vectorZ = Vector3D(-1, 0, 0)
            vectorX = Vector3D(0, 1, 0)
        end
    elseif direction == "back" then
        vectorZ = Vector3D(0, 1, 0)
        vectorX = Vector3D(1, 0, 0)
    else
        vectorZ = Vector3D(0, 0, -1)
        vectorX = Vector3D(1, 0, 0)
    end

    local vectors = {z = vectorZ, x = vectorX}
    return vectors
end

-- Функция задает параметры трубного порта.
-- Для резьбового соединения используется ThreadSize,
-- для остальных вариантов - NominalDiameter.
local function setPipeAttributes(port, portParameters)
    return parameters[portParameters].connectorType == PipeConnectorType.Thread
        and port:SetPipeParameters(parameters[portParameters].connectorType, parameters[portParameters].threadSize)
        or port:SetPipeParameters(parameters[portParameters].connectorType, parameters[portParameters].nominalDiameter)
end

-- Размещаем порт жидкостной линии и настраиваем его параметры.
Style.GetPort("WaterCoolant"):SetPlacement(Placement3D(waterCoolantOrigin,
                                            rotateVectors("WaterCoolant").z,
                                            rotateVectors("WaterCoolant").x))
setPipeAttributes(Style.GetPort("WaterCoolant"), "WaterCoolant")

-- Размещаем порт газовой линии.
Style.GetPort("GasCoolant"):SetPlacement(Placement3D(gasCoolantOrigin,
                                            rotateVectors("GasCoolant").z,
                                            rotateVectors("GasCoolant").x))
setPipeAttributes(Style.GetPort("GasCoolant"), "GasCoolant")

-- Размещаем порт дренажа.
Style.GetPort("Drainage"):SetPlacement(Placement3D(drainageOrigin,
                                            rotateVectors("Drainage").z,
                                            rotateVectors("Drainage").x))
setPipeAttributes(Style.GetPort("Drainage"), "Drainage")

-- Переходим к электрическим портам.
local halfHeight = height / 2

-- `direction` управляет тем, в какую сторону смещать соседние порты.
local direction = 1

local electricPortIntendation = parameters.ElectricConnectors.portIndentation
local distanceBetweenElectricPorts = parameters.ElectricConnectors.distanceBetweenPorts

-- Базовая точка электрических портов по умолчанию.
local electricConnectorsOrigin = Point3D(-distanceBetweenElectricPorts,
                                        halfWidth - electricPortIntendation,
                                        halfHeight)

-- Пересчитываем точку в зависимости от выбранного расположения группы электрических портов.
if parameters.ElectricConnectors.portLocation == "right" then
    electricConnectorsOrigin = Point3D(halfLengthWithIndent50,
                                        halfWidth - electricPortIntendation,
                                        halfHeight)
    direction = -1
elseif parameters.ElectricConnectors.portLocation == "left" then
    electricConnectorsOrigin = Point3D(-halfLengthWithIndent50,
                                        halfWidth - electricPortIntendation,
                                        halfHeight)
end

-- Силовой порт ставится в базовую точку.
Style.GetPort("PowerSupplyLine"):SetPlacement(Placement3D(
                                                electricConnectorsOrigin,
                                                Vector3D(0, 1, 0),
                                                Vector3D(1, 0, 0)))

-- Первый порт линии управления смещается относительно базовой точки.
Style.GetPort("ControlNetwork1"):SetPlacement(Placement3D(
                                                electricConnectorsOrigin
                                                :Shift(direction * distanceBetweenElectricPorts, 0, 0),
                                                Vector3D(0, 1, 0),
                                                Vector3D(1, 0, 0)))

-- Второй порт линии управления в текущем примере ставится в ту же смещенную точку.
-- Это можно воспринимать как место для самостоятельного улучшения примера.
Style.GetPort("ControlNetwork2"):SetPlacement(Placement3D(
                                                electricConnectorsOrigin
                                                :Shift(direction * distanceBetweenElectricPorts, 0, 0),
                                                Vector3D(0, 1, 0),
                                                Vector3D(1, 0, 0)))

-- Функция скрывает неактуальный параметр диаметра в зависимости от типа соединения.
local function hideIrrelevantPortParam(portName)
    local param = parameters[portName].connectorType == PipeConnectorType.Thread
      and "nominalDiameter" or "threadSize"
    Style.GetParameter(portName, param):SetVisible(false)
end

-- Применяем скрытие для всех трубных групп.
hideIrrelevantPortParam("WaterCoolant")
hideIrrelevantPortParam("GasCoolant")
hideIrrelevantPortParam("Drainage")
