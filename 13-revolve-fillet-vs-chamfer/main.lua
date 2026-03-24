local parameters = Style.GetParameterValues()

local radius = parameters.Dimensions.Radius
local height = parameters.Dimensions.Height
local straightChamfer = math.min(parameters.Dimensions.StraightChamfer, radius * 0.95, height * 0.95)
local bodyHeight = height - straightChamfer

local body = CreateRightCircularCylinder(radius, bodyHeight)

local bottomProfile = CreateCircle2D(Point2D(0, 0), radius)
local topProfile = CreateCircle2D(Point2D(0, 0), radius - straightChamfer)

local placements = {
    Placement3D(Point3D(0, 0, bodyHeight), Vector3D(0, 0, 1), Vector3D(1, 0, 0)),
    Placement3D(Point3D(0, 0, height), Vector3D(0, 0, 1), Vector3D(1, 0, 0))
}

local chamferPart = Loft({bottomProfile, topProfile}, placements, LoftParameters())
local solid = Unite({body, chamferPart})

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)
