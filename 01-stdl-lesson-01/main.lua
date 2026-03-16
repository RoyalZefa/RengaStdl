local parameters = Style.GetParameterValues()

local width = parameters.Dimensions.Width
local depth = parameters.Dimensions.Depth
local height = parameters.Dimensions.Height

print("TutorialBox:", width, depth, height)

local function makeTopViewSymbol()
    local geometrySet = GeometrySet2D()
    local rectangle = CreateRectangle2D(Point2D(0, 0), 0, width, depth)
    geometrySet:AddCurve(rectangle)
    return geometrySet
end

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(CreateBlock(width, depth, height))
Style.SetDetailedGeometry(detailedGeometry)

local symbolicGeometry = ModelGeometry()
local topViewPlacement = Placement3D(
    Point3D(0, 0, height),
    Vector3D(0, 0, 1),
    Vector3D(1, 0, 0)
)
symbolicGeometry:AddGeometrySet2D(makeTopViewSymbol(), topViewPlacement)
Style.SetSymbolicGeometry(symbolicGeometry)
