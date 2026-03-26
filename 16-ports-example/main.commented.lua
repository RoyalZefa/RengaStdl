--     16.
--       ,    08-minimal,
--      .
--
--     Renga STDL:
-- 1. Style.GetParameterValues() -  .
-- 2. CreatePolyline2D(...) + Extrude(...) -  .
-- 3. Style.GetPort("..."):SetPlacement(...) -   .
--
--       :
-- 1.  .
-- 2.   : ,   .
-- 3.     .

local parameters = Style.GetParameterValues()

--   .
local baseWidth = parameters.Dimensions.BaseWidth
local shoulderHeight = parameters.Dimensions.ShoulderHeight
local topWidth = parameters.Dimensions.TopWidth
local totalHeight = parameters.Dimensions.TotalHeight
local depth = parameters.Dimensions.Depth

-- ,      .
local sidePortHeight = parameters.Ports.SidePortHeight
local depthPosition = parameters.Ports.DepthPosition

--   ,         .
local halfBaseWidth = baseWidth / 2
local halfTopWidth = topWidth / 2

--     X-Z.
--   Point2D(...)   X.
--   Point2D(...)   Z.
local profilePoints = {
    --   .
    Point2D(-halfBaseWidth, 0),

    --   .
    Point2D(halfBaseWidth, 0),

    --      .
    Point2D(halfBaseWidth, shoulderHeight),

    --     .
    Point2D(halfTopWidth, totalHeight),

    --     .
    Point2D(-halfTopWidth, totalHeight),

    --      .
    Point2D(-halfBaseWidth, shoulderHeight),

    --   ,   .
    Point2D(-halfBaseWidth, 0)
}

--      .
local profile = CreatePolyline2D(profilePoints)

-- Placement3D       3D.
--    SDK :
-- Placement3D(point, zAxisDirection, xAxisDirection)
--
-- :
-- point = (0, 0, 0) -  .
-- zAxisDirection = (0, 1, 0) -       Y.
-- xAxisDirection = (1, 0, 0) -  X    X.
local placement = Placement3D(
    Point3D(0, 0, 0),
    Vector3D(0, 1, 0),
    Vector3D(1, 0, 0)
)

--     depth.
local solid = Extrude(profile, ExtrusionParameters(depth), placement)

--    Renga.
local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

--   ,       .
-- 1.       [0, depth].
-- 2.       [0, shoulderHeight],
--              .
local clampedDepthPosition = math.max(0, math.min(depthPosition, depth))
local clampedSidePortHeight = math.max(0, math.min(sidePortHeight, shoulderHeight))

--  :
-- origin      x = -halfBaseWidth.
--       clampedDepthPosition.
--   -  clampedSidePortHeight.
--
-- zAxisDirection = (-1, 0, 0) ,     .
-- xAxisDirection = (0, 1, 0) ,    X     .
local leftPortPlacement = Placement3D(
    Point3D(-halfBaseWidth, clampedDepthPosition, clampedSidePortHeight),
    Vector3D(-1, 0, 0),
    Vector3D(0, 1, 0)
)

--  :
-- origin      x = +halfBaseWidth.
--      ,    .
--
-- zAxisDirection = (1, 0, 0) ,     .
local rightPortPlacement = Placement3D(
    Point3D(halfBaseWidth, clampedDepthPosition, clampedSidePortHeight),
    Vector3D(1, 0, 0),
    Vector3D(0, 1, 0)
)

--  :
-- origin        z = totalHeight.
-- x = 0,     .
--       clampedDepthPosition.
--
-- zAxisDirection = (0, 0, 1) ,    .
-- xAxisDirection = (1, 0, 0) ,    X   .
local topPortPlacement = Placement3D(
    Point3D(0, clampedDepthPosition, totalHeight),
    Vector3D(0, 0, 1),
    Vector3D(1, 0, 0)
)

--   ,     geometry.json,
--      Placement3D.
Style.GetPort("LeftPort"):SetPlacement(leftPortPlacement)
Style.GetPort("RightPort"):SetPlacement(rightPortPlacement)
Style.GetPort("TopPort"):SetPlacement(topPortPlacement)

--   :
-- geometry.json  ,    .
--  main.lua :
-- 1.     ;
-- 2.   ;
-- 3.    .
