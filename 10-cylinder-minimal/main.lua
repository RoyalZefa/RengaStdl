local parameters = Style.GetParameterValues()

local radius = parameters.Dimensions.Radius
local height = parameters.Dimensions.Height
local shiftX = parameters.Dimensions.ShiftX
local shiftY = parameters.Dimensions.ShiftY
local shiftZ = parameters.Dimensions.ShiftZ

local solid = CreateRightCircularCylinder(radius, height)
    :Shift(shiftX, shiftY, shiftZ)

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)
