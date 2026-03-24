local parameters = Style.GetParameterValues()

local depth = parameters.Dimensions.Depth

local profilePoints = {
    Point2D(-47.4, -0.7),
    Point2D(-34.6, 0),
    Point2D(-34.5, 35.6),
    Point2D(0.1, 61.5),
    Point2D(0.2, 76),
    Point2D(-47.7, 39.7),
    Point2D(-47.4, -0.7)
}

local placement = Placement3D(
    Point3D(0, 0, 0),
    Vector3D(1, 0, 0),
    Vector3D(0, 1, 0)
)

local profile = CreatePolyline2D(profilePoints)
local originalSolid = Extrude(profile, ExtrusionParameters(depth), placement)

local mirroredSolid = originalSolid:Clone():Scale(Point3D(0, 0, 0), 1, -1, 1)

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(originalSolid)
detailedGeometry:AddSolid(mirroredSolid)
Style.SetDetailedGeometry(detailedGeometry)
