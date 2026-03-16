local parameters = Style.GetParameterValues()

local panelWidth = parameters.Dimensions.PanelWidth
local panelHeight = parameters.Dimensions.PanelHeight
local panelDepth = parameters.Dimensions.PanelDepth
local screenMargin = parameters.Dimensions.ScreenMargin

local isTableMount = parameters.Mounting.MountType == "Table"
Style.GetParameter("Mounting", "StandDepth"):SetVisible(isTableMount)

local body = CreateBlock(panelWidth, panelDepth, panelHeight)

local solid = body

if isTableMount then
    local standWidth = panelWidth * 0.35
    local standHeight = panelHeight * 0.08
    local standDepth = parameters.Mounting.StandDepth

    local stand = CreateBlock(standWidth, standDepth, standHeight)
        :Shift(0, panelDepth / 2 + standDepth / 2, -panelHeight / 2 + standHeight / 2)

    solid = Unite({body, stand})
end

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

local function createFrontSymbol()
    local geometry = GeometrySet2D()
    local outer = CreateRectangle2D(Point2D(0, 0), 0, panelWidth, panelHeight)
    local screen = CreateRectangle2D(
        Point2D(0, 0),
        0,
        panelWidth - screenMargin * 2,
        panelHeight - screenMargin * 2
    )

    geometry:AddCurve(outer)
    geometry:AddCurve(screen)
    geometry:AddMaterialColorSolidArea(FillArea(screen))
    return geometry
end

local symbolGeometry = ModelGeometry()
symbolGeometry:AddGeometrySet2D(createFrontSymbol())
Style.SetSymbolGeometry(symbolGeometry)

local symbolicGeometry = ModelGeometry()
local frontPlacement = Placement3D(
    Point3D(0, panelDepth / 2, 0),
    Vector3D(0, 1, 0),
    Vector3D(1, 0, 0)
)
symbolicGeometry:AddGeometrySet2D(createFrontSymbol(), frontPlacement)
Style.SetSymbolicGeometry(symbolicGeometry)
