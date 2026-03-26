local parameters = Style.GetParameterValues()

-- Размеры цилиндра.
local radius = parameters.Dimensions.Radius
local height = parameters.Dimensions.Height

-- Смещение всего тела в мировой системе координат.
local shiftX = parameters.Dimensions.ShiftX
local shiftY = parameters.Dimensions.ShiftY
local shiftZ = parameters.Dimensions.ShiftZ

-- Высота боковых портов.
local portHeight = parameters.Ports.PortHeight

-- Служебный параметр для самостоятельных экспериментов.
local portDepth = parameters.Ports.PortDepth

-- Строим цилиндр и сразу смещаем его.
local solid = CreateRightCircularCylinder(radius, height)
    :Shift(shiftX, shiftY, shiftZ)

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)

-- Левый порт находится на боковой поверхности слева.
local leftPortPlacement = Placement3D(
    Point3D(shiftX - radius, shiftY, shiftZ + portHeight),
    Vector3D(-1, 0, 0),
    Vector3D(0, 0, 1)
)

-- Правый порт находится на боковой поверхности справа.
local rightPortPlacement = Placement3D(
    Point3D(shiftX + radius, shiftY, shiftZ + portHeight),
    Vector3D(1, 0, 0),
    Vector3D(0, 0, 1)
)

-- Верхний порт расположен по центру верхнего основания цилиндра.
local topPortPlacement = Placement3D(
    Point3D(shiftX, shiftY, shiftZ + height),
    Vector3D(0, 0, 1),
    Vector3D(1, 0, 0)
)

Style.GetPort("LeftPort"):SetPlacement(leftPortPlacement)
Style.GetPort("RightPort"):SetPlacement(rightPortPlacement)
Style.GetPort("TopPort"):SetPlacement(topPortPlacement)
