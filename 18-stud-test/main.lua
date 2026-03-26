local parameters = Style.GetParameterValues()

local nominaldiameter = parameters.Dimensions.NominalDiameter
local widht = parameters.Dimensions.Widht
local depth = parameters.Dimensions.Depth
local symbolsize = parameters.SymbolSize.SymbolSize

local halfNominalDiameter = nominaldiameter / 2
local halfWidht = widht / 2

local profilePoints = {
    Point2D(-halfNominalDiameter, 0),
    Point2D(halfNominalDiameter, 0),
    Point2D(halfNominalDiameter, halfWidht),
    Point2D(halfNominalDiameter, halfWidht),
    Point2D(-halfNominalDiameter, 0)
}

local profile = CreatePolyline2D(profilePoints)

local placement = Placement3D(
    Point3D(0, 0, 0),
    Vector3D(0, 0, 1),
    Vector3D(1, 0, 0)
)

local solid = Extrude(profile, ExtrusionParameters(depth), placement)

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)