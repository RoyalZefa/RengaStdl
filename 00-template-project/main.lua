local parameters = Style.GetParameterValues()

local width = parameters.Dimensions.Width
local depth = parameters.Dimensions.Depth
local height = parameters.Dimensions.Height

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(CreateBlock(width, depth, height))
Style.SetDetailedGeometry(detailedGeometry)

local function createTopSymbol()
    local geometry = GeometrySet2D()
    geometry:AddCurve(CreateRectangle2D(Point2D(0, 0), 0, width, depth))
    return geometry
end

local symbolGeometry = ModelGeometry()
symbolGeometry:AddGeometrySet2D(createTopSymbol())
Style.SetSymbolGeometry(symbolGeometry)

local symbolicGeometry = ModelGeometry()
local topPlacement = Placement3D(
    Point3D(0, 0, height),
    Vector3D(0, 0, 1),
    Vector3D(1, 0, 0)
)
symbolicGeometry:AddGeometrySet2D(createTopSymbol(), topPlacement)
Style.SetSymbolicGeometry(symbolicGeometry)
