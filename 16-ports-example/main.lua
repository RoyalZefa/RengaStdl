local parameters = Style.GetParameterValues()

local baseWidth = parameters.Dimensions.BaseWidth
local shoulderHeight = parameters.Dimensions.ShoulderHeight
local topWidth = parameters.Dimensions.TopWidth
local totalHeight = parameters.Dimensions.TotalHeight
local depth = parameters.Dimensions.Depth

local sidePortHeight = parameters.Ports.SidePortHeight
local depthPosition = parameters.Ports.DepthPosition

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

local placement = Placement3D(
    Point3D(0, 0, 0),
    Vector3D(0, 1, 0),
    Vector3D(1, 0, 0)
)

local solid = Extrude(profile, ExtrusionParameters(depth), placement)
detailedGeometry:AddSolid(solid)

local detailedGeometry = ModelGeometry()
Style.SetDetailedGeometry(detailedGeometry)

local clampedDepthPosition = 20
local clampedSidePortHeight = 20

local leftPortPlacement = Placement3D(
    Point3D(-halfBaseWidth, clampedDepthPosition, clampedSidePortHeight),
    Vector3D(-1, 0, 0),
    Vector3D(0, 1, 0)
)

local rightPortPlacement = Placement3D(
    Point3D(halfBaseWidth, clampedDepthPosition, clampedSidePortHeight),
    Vector3D(1, 0, 0),
    Vector3D(0, 1, 0)
)

local topPortPlacement = Placement3D(
    Point3D(0, clampedDepthPosition, totalHeight),
    Vector3D(0, 0, 1),
    Vector3D(1, 0, 0)
)

Style.GetPort("LeftPort"):SetPlacement(leftPortPlacement)
Style.GetPort("RightPort"):SetPlacement(rightPortPlacement)
Style.GetPort("TopPort"):SetPlacement(topPortPlacement)
