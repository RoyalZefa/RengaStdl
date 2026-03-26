local parameters = Style.GetParameterValues()

local radius = parameters.Dimensions.Radius
local height = parameters.Dimensions.Height
local shiftX = parameters.Dimensions.ShiftX
local shiftY = parameters.Dimensions.ShiftY
local shiftZ = parameters.Dimensions.ShiftZ

local portHeight = parameters.Ports.portHight
local portDepth = parameters.Ports.portDepth

local solid = CreateRightCircularCylinder(radius, height)
    :Shift(shiftX, shiftY, shiftZ)

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

local leftPortPlacement = Placement3D(
    Point3D(shiftX - radius, shiftY, shiftZ + portHeight),
    Vector3D(-1, 0, 0),
    Vector3D(0, 0, 1)
)

local rightPortPlacement = Placement3D(
    Point3D(shiftX + radius, shiftY, shiftZ + portHeight),
    Vector3D(1, 0, 0),
    Vector3D(0, 0, 1)
)

local topPortPlacement = Placement3D(
    Point3D(shiftX, shiftY, shiftZ + height),
    Vector3D(0, 0, 1),
    Vector3D(1, 0, 0)
)

Style.GetPort("LeftPort"):SetPlacement(leftPortPlacement)
Style.GetPort("RightPort"):SetPlacement(rightPortPlacement)
Style.GetPort("TopPort"):SetPlacement(topPortPlacement)