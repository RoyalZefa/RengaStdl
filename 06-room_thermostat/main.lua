local parameters = Style.GetParameterValues()

local bodyWidth = parameters.Dimensions.BodyWidth
local bodyHeight = parameters.Dimensions.BodyHeight
local bodyDepth = parameters.Dimensions.BodyDepth
local dialDiameter = parameters.Dimensions.DialDiameter

local hasScreen = parameters.Display.HasScreen == "Yes"
Style.GetParameter("Display", "ScreenHeight"):SetVisible(hasScreen)

local body = CreateBlock(bodyWidth, bodyDepth, bodyHeight)
local dial = CreateRightCircularCylinder(dialDiameter / 2, 6)
    :Shift(0, bodyDepth / 2, 0)

local solid = Unite({body, dial})

if hasScreen then
    local screen = CreateBlock(bodyWidth * 0.45, 2, parameters.Display.ScreenHeight)
        :Shift(0, bodyDepth / 2, bodyHeight * 0.2)
    solid = Unite({solid, screen})
end

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

local function createSymbol()
    local geometry = GeometrySet2D()
    local contour = CreateRectangle2D(Point2D(0, 0), 0, bodyWidth, bodyHeight)
    local dial = CreateCircle2D(Point2D(0, -bodyHeight * 0.1), dialDiameter / 2)
    geometry:AddCurve(contour)
    geometry:AddCurve(dial)
    if hasScreen then
        local screen = CreateRectangle2D(Point2D(0, bodyHeight * 0.22), 0, bodyWidth * 0.45, parameters.Display.ScreenHeight)
        geometry:AddCurve(screen)
        geometry:AddMaterialColorSolidArea(FillArea(screen))
    end
    return geometry
end

local symbolGeometry = ModelGeometry()
symbolGeometry:AddGeometrySet2D(createSymbol())
Style.SetSymbolGeometry(symbolGeometry)

local symbolicGeometry = ModelGeometry()
local frontPlacement = Placement3D(
    Point3D(0, bodyDepth / 2, 0),
    Vector3D(0, 1, 0),
    Vector3D(1, 0, 0)
)
symbolicGeometry:AddGeometrySet2D(createSymbol(), frontPlacement)
Style.SetSymbolicGeometry(symbolicGeometry)

local controlPort = Style.GetPort("ControlLine")
controlPort:SetPlacement(Placement3D(
    Point3D(0, -bodyDepth / 2, 0),
    Vector3D(0, -1, 0),
    Vector3D(1, 0, 0)
))
