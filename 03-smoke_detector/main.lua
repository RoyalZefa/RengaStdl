local parameters = Style.GetParameterValues()

local bodyDiameter = parameters.Dimensions.BodyDiameter
local bodyHeight = parameters.Dimensions.BodyHeight
local baseDiameter = parameters.Dimensions.BaseDiameter
local baseHeight = parameters.Dimensions.BaseHeight
local cableLength = parameters.Dimensions.CableLength

local mountType = parameters.Mounting.MountType
local indicatorMode = parameters.Indicator.IndicatorMode
local terminalOffset = parameters.Electric.TerminalOffset
local portLayout = parameters.Electric.PortLayout

local bodyRadius = bodyDiameter / 2
local baseRadius = baseDiameter / 2
local indicatorRadius = parameters.Indicator.IndicatorDiameter / 2

local isCeilingMount = mountType == "Ceiling"
local isBuiltInIndicator = indicatorMode == "BuiltIn"

Style.GetParameter("Mounting", "CeilingOffset"):SetVisible(isCeilingMount)
Style.GetParameter("Mounting", "WallOffset"):SetVisible(not isCeilingMount)
Style.GetParameter("Indicator", "IndicatorDiameter"):SetVisible(isBuiltInIndicator)
Style.GetParameter("Indicator", "RemoteIndicatorCable"):SetVisible(not isBuiltInIndicator)

local mountOffset = isCeilingMount and parameters.Mounting.CeilingOffset or parameters.Mounting.WallOffset

local baseSolid = CreateRightCircularCylinder(baseRadius, baseHeight)
local bodySolid = CreateRightCircularCylinder(bodyRadius, bodyHeight)
    :Shift(0, 0, baseHeight)

local indicatorSolid = CreateRightCircularCylinder(indicatorRadius, 2)
    :Shift(bodyRadius * 0.35, 0, baseHeight + bodyHeight - 2)

local solid = isBuiltInIndicator
    and Unite({baseSolid, bodySolid, indicatorSolid})
    or Unite({baseSolid, bodySolid})

solid = solid:Shift(0, 0, -mountOffset)

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

local function createDetectorSymbol()
    local geometry = GeometrySet2D()
    local outer = CreateCircle2D(Point2D(0, 0), baseRadius)
    local inner = CreateCircle2D(Point2D(0, 0), bodyRadius * 0.65)

    geometry:AddCurve(outer)
    geometry:AddCurve(inner)
    geometry:AddMaterialColorSolidArea(FillArea(outer))
    geometry:AddCurve(CreateLineSegment2D(Point2D(-bodyRadius * 0.45, 0), Point2D(bodyRadius * 0.45, 0)))
    geometry:AddCurve(CreateLineSegment2D(Point2D(0, -bodyRadius * 0.45), Point2D(0, bodyRadius * 0.45)))
    return geometry
end

local symbolGeometry = ModelGeometry()
symbolGeometry:AddGeometrySet2D(createDetectorSymbol())
Style.SetSymbolGeometry(symbolGeometry)

local symbolicGeometry = ModelGeometry()
local symbolPlacement = Placement3D(
    Point3D(0, 0, baseHeight + bodyHeight - mountOffset),
    Vector3D(0, 0, 1),
    Vector3D(1, 0, 0)
)
symbolicGeometry:AddGeometrySet2D(createDetectorSymbol(), symbolPlacement)
Style.SetSymbolicGeometry(symbolicGeometry)

local function shiftPlacementByZ(placement, shift)
    local vector = placement:GetZAxisDirection()
    return placement:Clone():Shift(
        vector:GetX() * shift,
        vector:GetY() * shift,
        vector:GetZ() * shift
    )
end

local portZ = baseHeight / 2 - mountOffset
local terminalX1 = -terminalOffset
local terminalX2 = portLayout == "Opposite" and terminalOffset or 0

local powerPlacement = Placement3D(
    Point3D(terminalX1, 0, portZ),
    Vector3D(0, 0, -1),
    Vector3D(1, 0, 0)
)

local alarmPlacement = Placement3D(
    Point3D(terminalX2, 0, portZ),
    Vector3D(0, 0, -1),
    Vector3D(1, 0, 0)
)

local powerSupplyPort = Style.GetPort("PowerSupply")
powerSupplyPort:SetPlacement(shiftPlacementByZ(powerPlacement, cableLength))

local alarmLoopPort = Style.GetPort("AlarmLoop")
alarmLoopPort:SetPlacement(shiftPlacementByZ(alarmPlacement, cableLength))
