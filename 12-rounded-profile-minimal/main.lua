local parameters = Style.GetParameterValues()

local baseWidth = parameters.Dimensions.BaseWidth
local shoulderHeight = parameters.Dimensions.ShoulderHeight
local topWidth = parameters.Dimensions.TopWidth
local totalHeight = parameters.Dimensions.TotalHeight
local depth = parameters.Dimensions.Depth
local filletRadius = parameters.Dimensions.FilletRadius

local halfBaseWidth = baseWidth / 2
local halfTopWidth = topWidth / 2

local profilePoints = {
    Point2D(-halfBaseWidth, 0),
    Point2D(halfBaseWidth, 0),
    Point2D(halfBaseWidth, shoulderHeight),
    Point2D(halfTopWidth, totalHeight),
    Point2D(-halfTopWidth, totalHeight),
    Point2D(-halfBaseWidth, shoulderHeight),
    Point2D(-halfBaseWidth, 0)
}

local profile = CreatePolyline2D(profilePoints)
FilletCornerAfterSegment2D(profile, 2, filletRadius)

local placement = Placement3D(
    Point3D(0, 0, 0),
    Vector3D(0, 1, 0),
    Vector3D(1, 0, 0)
)

local solid = Extrude(profile, ExtrusionParameters(depth), placement)

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)
