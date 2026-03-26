-- Получаем все значения параметров из JSON.
local parameters = Style.GetParameterValues()

-- Читаем простые размеры тела.
local radius = parameters.Dimensions.Radius
local height = parameters.Dimensions.Height
local portHeight = parameters.PortControl.PortHeight

-- enum - это параметр с готовым списком значений.
-- Пользователь не пишет любое слово руками, а выбирает одно значение из списка.
--
-- В этом примере:
-- - PipeConnectorType - тип трубного соединения:
--   Weld, Flange, Thread и другие.
-- - PipeThreadSize - размер резьбы:
--   D0_25, D0_50, D1_0 и т.д.
--
-- Мы берем текущее выбранное значение enum через GetValue().
local connectionType = Style.GetParameter("Connection", "ConnectionType"):GetValue()
local portState = Style.GetParameter("PortControl", "PortState"):GetValue()

-- Проверяем, включен ли порт.
local hasPort = portState == "Enabled"

-- Проверяем, выбран ли резьбовой тип подключения.
local isThread = connectionType == PipeConnectorType.Thread

-- SetEnabled отключает параметр или группу, но не прячет ее.
-- Пользователь все еще видит параметр, но не может его менять.
Style.GetParameterGroup("Connection"):SetEnabled(hasPort)
Style.GetParameter("PortControl", "PortHeight"):SetEnabled(hasPort)

-- SetVisible прячет параметр совсем.
-- Здесь мы оставляем только тот параметр, который нужен для текущего типа соединения.
Style.GetParameter("Connection", "ThreadSize"):SetVisible(hasPort and isThread)
Style.GetParameter("Connection", "NominalDiameter"):SetVisible(hasPort and not isThread)

-- Строим очень простое тело: цилиндр.
local solid = CreateRightCircularCylinder(radius, height)

-- Передаем геометрию в стиль.
local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

-- Эта функция показывает главный смысл урока.
-- Один и тот же порт получает параметры по-разному:
-- - если соединение резьбовое, передаем PipeThreadSize
-- - если нет, передаем обычный номинальный диаметр
local function setPipeParameters(port)
    if isThread then
        port:SetPipeParameters(connectionType, parameters.Connection.ThreadSize)
    else
        port:SetPipeParameters(connectionType, parameters.Connection.NominalDiameter)
    end
end

-- Если порт включен, размещаем его на боковой поверхности цилиндра.
if hasPort then
    local portPlacement = Placement3D(
        Point3D(radius, 0, portHeight),
        Vector3D(1, 0, 0),
        Vector3D(0, 0, 1)
    )

    local waterInlet = Style.GetPort("WaterInlet")
    waterInlet:SetPlacement(portPlacement)

    -- Здесь port получает инженерные параметры подключения.
    setPipeParameters(waterInlet)
end
