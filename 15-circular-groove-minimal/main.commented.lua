local parameters = Style.GetParameterValues()

-- Размеры основного тела.
-- В этом уроке основное тело специально самое простое:
-- обычный цилиндр.
local radius = parameters.Body.Radius
local bodyHeight = parameters.Body.Height

-- Размеры блока-вырезателя.
local cutWidth = parameters.Cut.Width
local cutDepth = parameters.Cut.Depth
local cutHeight = parameters.Cut.Height
local cutOffsetX = parameters.Cut.OffsetX

-- Строим основное тело.
-- CreateRightCircularCylinder(radius, height) создает цилиндр
-- от z = 0 до z = bodyHeight.
local body = CreateRightCircularCylinder(radius, bodyHeight)

-- Строим вырезатель.
-- Здесь вырезатель - это обычный блок.
--
-- CreateBlock(width, depth, height) строит тело симметрично
-- относительно собственного центра.
-- Поэтому после Shift(..., ..., bodyHeight / 2)
-- центр блока окажется посередине высоты цилиндра.
--
-- Если cutDepth и cutHeight больше размеров цилиндра,
-- блок пройдет насквозь и вырежет заметный паз.
local cutter = CreateBlock(cutWidth, cutDepth, cutHeight)
    :Shift(cutOffsetX, 0, bodyHeight / 2)

-- Главная операция примера:
-- из основного тела вычитаем тело-вырезатель.
--
-- Было:
--   body
--
-- Вычитаем:
--   cutter
--
-- Получаем:
--   body с вырезом
local resultSolid = Subtract(body, cutter)

local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(resultSolid)
Style.SetDetailedGeometry(detailedGeometry)
