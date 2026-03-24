-- Учебная версия `main.lua` проекта `07-student-test`.
-- Это упрощенная модель подвесного спринклера по изображению из технического паспорта.
-- Типовой каркас STDL здесь такой же, как и в других проектах:
-- чтение параметров, построение 3D, построение 2D и настройка порта.

local parameters = Style.GetParameterValues()

local bodyDiameter = parameters.Dimensions.BodyDiameter
local bodyHeight = parameters.Dimensions.BodyHeight
local nutDiameter = parameters.Dimensions.NutDiameter
local nutHeight = parameters.Dimensions.NutHeight
local frameHeight = parameters.Dimensions.FrameHeight
local frameThickness = parameters.Dimensions.FrameThickness
local frameOffset = parameters.Dimensions.FrameOffset
local stemDiameter = parameters.Dimensions.StemDiameter
local stemHeight = parameters.Dimensions.StemHeight
local deflectorDiameter = parameters.Dimensions.DeflectorDiameter
local deflectorThickness = parameters.Dimensions.DeflectorThickness

local isThread =
    Style.GetParameter("Connection", "ConnectionType"):GetValue() ==
        PipeConnectorType.Thread
Style.GetParameter("Connection", "ThreadSize"):SetVisible(isThread)
Style.GetParameter("Connection", "NominalDiameter"):SetVisible(not isThread)

local bodyRadius = bodyDiameter / 2
local nutRadius = nutDiameter / 2
local stemRadius = stemDiameter / 2
local deflectorRadius = deflectorDiameter / 2

local body = CreateRightCircularCylinder(bodyRadius, bodyHeight)
local nut = CreateRightCircularCylinder(nutRadius, nutHeight)
    :Shift(0, 0, bodyHeight)

local armDepth = frameThickness
local leftArm = CreateBlock(frameThickness, armDepth, frameHeight)
    :Shift(-frameOffset, 0, bodyHeight + nutHeight + frameHeight / 2)
local rightArm = CreateBlock(frameThickness, armDepth, frameHeight)
    :Shift(frameOffset, 0, bodyHeight + nutHeight + frameHeight / 2)

local stem = CreateRightCircularCylinder(stemRadius, stemHeight)
    :Shift(0, 0, bodyHeight + nutHeight + frameHeight)

local deflector = CreateRightCircularCylinder(deflectorRadius, deflectorThickness)
    :Shift(0, 0, bodyHeight + nutHeight + frameHeight + stemHeight)

local solid = Unite({body, nut, leftArm, rightArm, stem, deflector})

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

local function createTopSymbol()
    local geometry = GeometrySet2D()
    local outer = CreateCircle2D(Point2D(0, 0), deflectorRadius)
    local middle = CreateCircle2D(Point2D(0, 0), 10)
    local inlet = CreateCircle2D(Point2D(0, 0), 5)

    geometry:AddCurve(outer)
    geometry:AddCurve(middle)
    geometry:AddCurve(inlet)
    geometry:AddMaterialColorSolidArea(FillArea(outer))
    geometry:AddCurve(CreateLineSegment2D(Point2D(-deflectorRadius, 0), Point2D(deflectorRadius, 0)))
    geometry:AddCurve(CreateLineSegment2D(Point2D(0, -deflectorRadius), Point2D(0, deflectorRadius)))

    return geometry
end

local symbolGeometry = ModelGeometry()
symbolGeometry:AddGeometrySet2D(createTopSymbol())
Style.SetSymbolGeometry(symbolGeometry)

local symbolicGeometry = ModelGeometry()
local topPlacement = Placement3D(
    Point3D(0, 0, bodyHeight + nutHeight + frameHeight + stemHeight + deflectorThickness),
    Vector3D(0, 0, 1),
    Vector3D(1, 0, 0)
)
symbolicGeometry:AddGeometrySet2D(createTopSymbol(), topPlacement)
Style.SetSymbolicGeometry(symbolicGeometry)

local function setPipeParameters(port, connection)
    if connection.ConnectionType == PipeConnectorType.Thread then
        port:SetPipeParameters(connection.ConnectionType, connection.ThreadSize)
    else
        port:SetPipeParameters(connection.ConnectionType, connection.NominalDiameter)
    end
end

local portPlacement = Placement3D(
    Point3D(0, 0, 0),
    Vector3D(0, 0, -1),
    Vector3D(1, 0, 0)
)

local waterSupply = Style.GetPort("WaterSupply")
waterSupply:SetPlacement(portPlacement)
setPipeParameters(waterSupply, parameters.Connection)
