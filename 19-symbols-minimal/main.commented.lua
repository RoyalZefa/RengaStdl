local parameters = Style.GetParameterValues()
require("library")

-- `require("library")` подключает файл library.lua.
-- Именно поэтому функции создания символов становятся доступны в main.lua.

-- Читаем размеры из группы Dimensions.
local baseWidth = parameters.Dimensions.BaseWidth
local shoulderHeight = parameters.Dimensions.ShoulderHeight
local topWidth = parameters.Dimensions.TopWidth
local totalHeight = parameters.Dimensions.TotalHeight
local depth = parameters.Dimensions.Depth

-- Из группы Symbols берем только общий размер символа.
-- Какой именно символ использовать, пользователь выбирает
-- вручную ниже, редактируя main.lua.
local symbolSize = parameters.Symbols.SymbolSize

local halfBaseWidth = baseWidth / 2
local halfTopWidth = topWidth / 2

-- Это тот же профиль, что и в 08-minimal:
-- сначала широкое основание,
-- потом прямые боковины,
-- потом сужение к верхней части.
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

-- Placement3D задает:
-- Point3D  = откуда начинается локальная система профиля,
-- Vector3D = куда смотрит локальная ось Z профиля,
-- Vector3D = куда смотрит локальная ось X профиля.
local placement = Placement3D(
    Point3D(0, 0, 0),
    Vector3D(0, 1, 0),
    Vector3D(1, 0, 0)
)

-- Превращаем 2D-профиль в 3D-тело.
local solid = Extrude(profile, ExtrusionParameters(depth), placement)

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

-- Функции создания символов больше не лежат в этом файле.
-- Они вынесены в library.lua, чтобы main.lua оставался короче и чище.
-- Это хороший учебный пример разделения:
-- library.lua = где описаны инструменты,
-- main.lua    = где выбирается, какой инструмент использовать.

-- По умолчанию берем символ "круг с крестом".
-- Здесь выбирается нужный символ.
-- Пользователь может вручную заменить строку ниже, например, на:
-- local selectedSymbol = createRectangleSymbol(symbolSize)
-- local selectedSymbol = createDiamondSymbol(symbolSize)
-- local selectedSymbol = createScreenSymbol(symbolSize)
local selectedSymbol = createCircleCrossSymbol(symbolSize)

-- SetSymbolGeometry задает обычный 2D-символ объекта.
local symbolGeometry = ModelGeometry()
symbolGeometry:AddGeometrySet2D(selectedSymbol)
Style.SetSymbolGeometry(symbolGeometry)

-- SetSymbolicGeometry показывает тот же символ уже в 3D-пространстве модели.
-- Мы ставим его на переднюю грань тела.
local symbolicGeometry = ModelGeometry()
local frontPlacement = Placement3D(
    Point3D(0, depth, totalHeight / 2),
    Vector3D(0, 1, 0),
    Vector3D(1, 0, 0)
)
symbolicGeometry:AddGeometrySet2D(selectedSymbol, frontPlacement)
Style.SetSymbolicGeometry(symbolicGeometry)
