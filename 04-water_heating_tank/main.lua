local parameters = Style.GetParameterValues()

local tankDiameter = parameters.Dimensions.TankDiameter
local tankHeight = parameters.Dimensions.TankHeight
local nozzleLength = parameters.Dimensions.NozzleLength
local coldWaterLevel = parameters.Dimensions.ColdWaterLevel
local hotWaterLevel = parameters.Dimensions.HotWaterLevel

local tankRadius = tankDiameter / 2
local portsSide = parameters.WaterConnections.PortsSide
local cableSide = parameters.Electric.CableSide

local nozzleDirection = portsSide == "right" and 1 or -1
local cableDirection = cableSide == "right" and 1 or -1

local function getPipePlacement(zLevel)
    return Placement3D(
        Point3D(nozzleDirection * tankRadius, 0, zLevel - tankHeight / 2),
        Vector3D(nozzleDirection, 0, 0),
        Vector3D(0, 0, 1)
    )
end

local coldWaterPlacement = getPipePlacement(coldWaterLevel)
local hotWaterPlacement = getPipePlacement(hotWaterLevel)

local powerPlacement = Placement3D(
    Point3D(cableDirection * tankRadius, 0, parameters.Electric.CableHeight - tankHeight / 2),
    Vector3D(cableDirection, 0, 0),
    Vector3D(0, 0, 1)
)

local function hideIrrelevantPipePortParams(groupName)
    local isThread =
        Style.GetParameter(groupName, "ConnectionType"):GetValue() ==
            PipeConnectorType.Thread

    Style.GetParameter(groupName, "ThreadSize"):SetVisible(isThread)
    Style.GetParameter(groupName, "NominalDiameter"):SetVisible(not isThread)
end

hideIrrelevantPipePortParams("WaterConnections")

local tankBody = CreateRightCircularCylinder(tankRadius, tankHeight)
    :Shift(0, 0, -tankHeight / 2)

local nozzleRadius = parameters.WaterConnections.NominalDiameter / 2
local nozzlePrototype = CreateRightCircularCylinder(nozzleRadius, nozzleLength)

local coldNozzle = nozzlePrototype:Clone():Transform(coldWaterPlacement:GetMatrix())
local hotNozzle = nozzlePrototype:Clone():Transform(hotWaterPlacement:GetMatrix())

local solid = Unite({tankBody, coldNozzle, hotNozzle})

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

local function createTopSymbol()
    local geometry = GeometrySet2D()
    local contour = CreateCircle2D(Point2D(0, 0), tankRadius)
    geometry:AddCurve(contour)
    geometry:AddMaterialColorSolidArea(FillArea(contour))
    geometry:AddCurve(CreateLineSegment2D(Point2D(0, -tankRadius * 0.6), Point2D(0, tankRadius * 0.6)))
    geometry:AddCurve(CreateLineSegment2D(Point2D(-tankRadius * 0.25, 0), Point2D(tankRadius * 0.25, 0)))
    return geometry
end

local symbolGeometry = ModelGeometry()
symbolGeometry:AddGeometrySet2D(createTopSymbol())
Style.SetSymbolGeometry(symbolGeometry)

local symbolicGeometry = ModelGeometry()
local topPlacement = Placement3D(
    Point3D(0, 0, tankHeight / 2),
    Vector3D(0, 0, 1),
    Vector3D(1, 0, 0)
)
symbolicGeometry:AddGeometrySet2D(createTopSymbol(), topPlacement)
Style.SetSymbolicGeometry(symbolicGeometry)

local function shiftPlacementByZ(placement, shift)
    local vector = placement:GetZAxisDirection()
    return placement:Clone():Shift(
        vector:GetX() * shift,
        vector:GetY() * shift,
        vector:GetZ() * shift
    )
end

local function setPipeParameters(port, portParameters)
    local connectionType = portParameters.ConnectionType
    if connectionType == PipeConnectorType.Thread then
        port:SetPipeParameters(connectionType, portParameters.ThreadSize)
    else
        port:SetPipeParameters(connectionType, portParameters.NominalDiameter)
    end
end

local coldWaterPort = Style.GetPort("ColdWaterInlet")
coldWaterPort:SetPlacement(shiftPlacementByZ(coldWaterPlacement, nozzleLength))
setPipeParameters(coldWaterPort, parameters.WaterConnections)

local hotWaterPort = Style.GetPort("HotWaterOutlet")
hotWaterPort:SetPlacement(shiftPlacementByZ(hotWaterPlacement, nozzleLength))
setPipeParameters(hotWaterPort, parameters.WaterConnections)

local powerSupplyPort = Style.GetPort("PowerSupply")
powerSupplyPort:SetPlacement(powerPlacement)
