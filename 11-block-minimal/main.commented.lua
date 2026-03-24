-- Минимальный учебный STDL-скрипт только про CreateBlock.
-- Этот пример нужен, чтобы понять:
-- 1. как задаются размеры блока;
-- 2. чем блок отличается от цилиндра по положению относительно начала координат;
-- 3. как Shift(...) двигает готовое тело.

-- Получаем параметры из geometry.json.
local parameters = Style.GetParameterValues()

-- Читаем размеры блока.
local width = parameters.Dimensions.Width
local depth = parameters.Dimensions.Depth
local height = parameters.Dimensions.Height

-- Читаем сдвиг по мировым осям.
local shiftX = parameters.Dimensions.ShiftX
local shiftY = parameters.Dimensions.ShiftY
local shiftZ = parameters.Dimensions.ShiftZ

-- Создаем блок.
-- Функция CreateBlock(width, depth, height) строит прямоугольный объем так:
--
-- - размер width идет вдоль оси X;
-- - размер depth идет вдоль оси Y;
-- - размер height идет вдоль оси Z.
--
-- Самое важное отличие от цилиндра:
-- CreateBlock сразу строит тело симметрично относительно начала координат.
--
-- То есть без сдвига блок занимает такие диапазоны:
--
-- X: от -width / 2  до  width / 2
-- Y: от -depth / 2  до  depth / 2
-- Z: от -height / 2 до  height / 2
--
-- Схема:
--
--            Z
--            ^
--            |
--      верх: +height/2
--            |
--       O ---+--- центр блока
--            |
--       низ: -height/2
--
-- Это нужно особенно хорошо запомнить:
-- у блока центр совпадает с началом координат,
-- а у цилиндра основание начинается от z = 0 и идет вверх.
local solid = CreateBlock(width, depth, height)
    :Shift(shiftX, shiftY, shiftZ)

-- После Shift(...) блок сохраняет форму и размеры,
-- но меняет положение в мировой системе координат.

-- Создаем контейнер детальной геометрии.
local detailedGeometry = ModelGeometry()

-- Добавляем туда построенный блок.
detailedGeometry:AddSolid(solid)

-- Передаем результат в Renga.
Style.SetDetailedGeometry(detailedGeometry)
