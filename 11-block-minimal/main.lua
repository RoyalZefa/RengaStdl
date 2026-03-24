local parameters = Style.GetParameterValues()

local width = parameters.Dimensions.Width
local depth = parameters.Dimensions.Depth
local height = parameters.Dimensions.Height
local shiftX = parameters.Dimensions.ShiftX
local shiftY = parameters.Dimensions.ShiftY
local shiftZ = parameters.Dimensions.ShiftZ

local solid = CreateBlock(width, depth, height)
    :Shift(shiftX, shiftY, shiftZ)

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)
