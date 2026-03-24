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

local function makeHexProfile(radius)
    local points = {}
    for i = 0, 5 do
        local angle = math.rad(30 + i * 60)
        points[#points + 1] = Point2D(radius * math.cos(angle), radius * math.sin(angle))
    end
    points[#points + 1] = points[1]
    return CreatePolyline2D(points)
end

local function createHexNut(radius, height, baseZ)
    local profile = makeHexProfile(radius)
    local placement = Placement3D(
        Point3D(0, 0, baseZ),
        Vector3D(0, 0, 1),
        Vector3D(1, 0, 0)
    )
    return Extrude(profile, ExtrusionParameters(height), placement)
end

local function buildHalfArcPoints(radius, legHeight, steps, reverse)
    local points = {}
    local startAngle = reverse and 0 or math.pi
    local finishAngle = reverse and math.pi or 0
    for i = 0, steps do
        local t = i / steps
        local angle = startAngle + (finishAngle - startAngle) * t
        points[#points + 1] = Point2D(radius * math.cos(angle), legHeight + radius * math.sin(angle))
    end
    return points
end

local function createFrontArchContour(outerHalfWidth, innerHalfWidth, totalHeight, shoulderHeight)
    local points = {
        Point2D(-outerHalfWidth, 0),
        Point2D(-outerHalfWidth, shoulderHeight),
        Point2D(-innerHalfWidth, totalHeight),
        Point2D(innerHalfWidth, totalHeight),
        Point2D(outerHalfWidth, shoulderHeight),
        Point2D(outerHalfWidth, 0),
        Point2D(-outerHalfWidth, 0)
    }
    return CreatePolyline2D(points)
end

local function createFrontArch(outerHalfWidth, innerHalfWidth, totalHeight, thickness, baseZ)
    local shoulderHeight = totalHeight * 0.72
    local placement = Placement3D(
        Point3D(0, -thickness / 2, baseZ),
        Vector3D(0, 1, 0),
        Vector3D(1, 0, 0)
    )

    local outerSolid = Extrude(
        createFrontArchContour(outerHalfWidth, innerHalfWidth, totalHeight, shoulderHeight),
        ExtrusionParameters(thickness),
        placement
    )

    local innerShoulderHeight = shoulderHeight - frameThickness * 0.4
    local innerBottomOffset = frameThickness
    local innerSolid = Extrude(
        CreatePolyline2D({
            Point2D(-outerHalfWidth + innerBottomOffset, 0),
            Point2D(-outerHalfWidth + innerBottomOffset, innerShoulderHeight),
            Point2D(-innerHalfWidth + frameThickness * 0.55, totalHeight - frameThickness),
            Point2D(innerHalfWidth - frameThickness * 0.55, totalHeight - frameThickness),
            Point2D(outerHalfWidth - innerBottomOffset, innerShoulderHeight),
            Point2D(outerHalfWidth - innerBottomOffset, 0),
            Point2D(-outerHalfWidth + innerBottomOffset, 0)
        }),
        ExtrusionParameters(thickness + 0.2),
        Placement3D(
            Point3D(0, -thickness / 2 - 0.1, baseZ),
            Vector3D(0, 1, 0),
            Vector3D(1, 0, 0)
        )
    )

    return Subtract(outerSolid, innerSolid)
end

local body = CreateRightCircularCylinder(bodyRadius, bodyHeight)

local nut = createHexNut(nutRadius, nutHeight, bodyHeight)

local archOuterHalfWidth = math.max(frameOffset + frameThickness * 1.35, stemRadius * 2.6)
local archInnerHalfWidth = math.max(stemRadius * 1.5, archOuterHalfWidth * 0.22)
local archHeight = math.max(frameHeight, archOuterHalfWidth * 1.45)
local archBaseZ = bodyHeight + nutHeight

local arch = createFrontArch(
    archOuterHalfWidth,
    archInnerHalfWidth,
    archHeight,
    frameThickness,
    archBaseZ
)

local stemBaseZ = archBaseZ + frameThickness
local stem = CreateRightCircularCylinder(stemRadius, stemHeight)
    :Shift(0, 0, stemBaseZ)

local gearBaseZ = stemBaseZ + stemHeight + 1
local gearCore = CreateRightCircularCylinder(deflectorRadius * 0.42, deflectorThickness)
    :Shift(0, 0, gearBaseZ)
local gearHub = CreateRightCircularCylinder(deflectorRadius * 0.18, deflectorThickness)
    :Shift(0, 0, gearBaseZ)

local tabLength = deflectorRadius * 0.45
local tabWidth = deflectorRadius * 0.22
local tabCenterX = deflectorRadius * 0.55
local tabCenterZ = gearBaseZ + deflectorThickness / 2
local tabPrototype = CreateBlock(tabLength, tabWidth, deflectorThickness)
    :Shift(tabCenterX, 0, tabCenterZ)
local tabs = {}
for i = 0, 5 do
    tabs[#tabs + 1] = tabPrototype:Clone():Rotate(CreateZAxis3D(), i * math.pi / 3)
end

local deflectorParts = {gearCore, gearHub}
for i = 1, #tabs do
    deflectorParts[#deflectorParts + 1] = tabs[i]
end
local gear = Unite(deflectorParts)

local solid = Unite({
    body,
    nut,
    arch,
    stem,
    gear
})

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

local function createTopSymbol()
    local geometry = GeometrySet2D()
    local outer = CreateCircle2D(Point2D(0, 0), deflectorRadius)
    local middle = CreateCircle2D(Point2D(0, 0), deflectorRadius * 0.42)
    local inlet = CreateCircle2D(Point2D(0, 0), deflectorRadius * 0.18)

    geometry:AddCurve(outer)
    geometry:AddCurve(middle)
    geometry:AddCurve(inlet)
    geometry:AddMaterialColorSolidArea(FillArea(outer))

    for i = 0, 5 do
        local angle = i * math.pi / 3
        geometry:AddCurve(
            CreateLineSegment2D(
                Point2D(math.cos(angle) * deflectorRadius * 0.45, math.sin(angle) * deflectorRadius * 0.45),
                Point2D(math.cos(angle) * deflectorRadius, math.sin(angle) * deflectorRadius)
            )
        )
    end

    return geometry
end

local symbolGeometry = ModelGeometry()
symbolGeometry:AddGeometrySet2D(createTopSymbol())
Style.SetSymbolGeometry(symbolGeometry)

local symbolicGeometry = ModelGeometry()
local topPlacement = Placement3D(
    Point3D(0, 0, gearBaseZ + deflectorThickness),
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
