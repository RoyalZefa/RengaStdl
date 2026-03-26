local parameters = Style.GetParameterValues()

local radius = parameters.Dimensions.Radius
local height = parameters.Dimensions.Height
local portHeight = parameters.PortControl.PortHeight

-- enum - это параметр, у которого нельзя вводить произвольный текст.
-- Пользователь выбирает одно готовое значение из списка.
-- Здесь ConnectionType - enum из SDK PipeConnectorType:
-- Weld, Flange, Thread и другие.
local connectionType = Style.GetParameter("Connection", "ConnectionType"):GetValue()
local portState = Style.GetParameter("PortControl", "PortState"):GetValue()

local hasPort = portState == "Enabled"
local isThread = connectionType == PipeConnectorType.Thread

-- SetEnabled отключает параметр или целую группу, но не скрывает ее.
Style.GetParameterGroup("Connection"):SetEnabled(hasPort)
Style.GetParameter("PortControl", "PortHeight"):SetEnabled(hasPort)

-- SetVisible полностью прячет или показывает параметр.
Style.GetParameter("Connection", "ThreadSize"):SetVisible(hasPort and isThread)
Style.GetParameter("Connection", "NominalDiameter"):SetVisible(hasPort and not isThread)

local solid = CreateRightCircularCylinder(radius, height)

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

local function setPipeParameters(port)
    if isThread then
        port:SetPipeParameters(connectionType, parameters.Connection.ThreadSize)
    else
        port:SetPipeParameters(connectionType, parameters.Connection.NominalDiameter)
    end
end

if hasPort then
    local portPlacement = Placement3D(
        Point3D(radius, 0, portHeight),
        Vector3D(1, 0, 0),
        Vector3D(0, 0, 1)
    )

    local waterInlet = Style.GetPort("WaterInlet")
    waterInlet:SetPlacement(portPlacement)
    setPipeParameters(waterInlet)
end
