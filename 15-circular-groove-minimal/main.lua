local parameters = Style.GetParameterValues()

local radius = parameters.Body.Radius
local bodyHeight = parameters.Body.Height

local cutWidth = parameters.Cut.Width
local cutDepth = parameters.Cut.Depth
local cutHeight = parameters.Cut.Height
local cutOffsetX = parameters.Cut.OffsetX

local body = CreateRightCircularCylinder(radius, bodyHeight)

local cutter = CreateBlock(cutWidth, cutDepth, cutHeight)
    :Shift(cutOffsetX, 0, bodyHeight / 2)

local resultSolid = Subtract(body, cutter)

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(resultSolid)
Style.SetDetailedGeometry(detailedGeometry)
