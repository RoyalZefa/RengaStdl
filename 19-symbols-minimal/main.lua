local parameters = Style.GetParameterValues()
require("library")

local baseWidth = parameters.Dimensions.BaseWidth
local shoulderHeight = parameters.Dimensions.ShoulderHeight
local topWidth = parameters.Dimensions.TopWidth
local totalHeight = parameters.Dimensions.TotalHeight
local depth = parameters.Dimensions.Depth

local symbolSize = parameters.Symbols.SymbolSize

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

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

-- Функции построения символов вынесены в library.lua.
-- Библиотеку нужно явно подключить через require("library").
-- Здесь мы вручную выбираем, какую именно функцию вызвать.
-- Можно заменить строку ниже на любой другой вариант:
-- createRectangleSymbol(symbolSize)
-- createCircleCrossSymbol(symbolSize)
-- createDiamondSymbol(symbolSize)
-- createScreenSymbol(symbolSize)
local selectedSymbol = createCircleCrossSymbol(symbolSize)

local symbolGeometry = ModelGeometry()
symbolGeometry:AddGeometrySet2D(selectedSymbol)
Style.SetSymbolGeometry(symbolGeometry)

local symbolicGeometry = ModelGeometry()
local frontPlacement = Placement3D(
    Point3D(0, depth, totalHeight / 2),
    Vector3D(0, 1, 0),
    Vector3D(1, 0, 0)
)
symbolicGeometry:AddGeometrySet2D(selectedSymbol, frontPlacement)
Style.SetSymbolicGeometry(symbolicGeometry)
