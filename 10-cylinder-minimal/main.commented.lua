-- Минимальный учебный STDL-скрипт только про цилиндр.
-- Здесь мы сознательно изучаем всего две идеи:
-- 1. как работает CreateRightCircularCylinder(radius, height);
-- 2. как Shift(...) меняет положение уже готового тела.

-- Получаем значения параметров из geometry.json.
local parameters = Style.GetParameterValues()

-- Читаем размеры цилиндра.
local radius = parameters.Dimensions.Radius
local height = parameters.Dimensions.Height

-- Читаем сдвиг по мировым осям.
local shiftX = parameters.Dimensions.ShiftX
local shiftY = parameters.Dimensions.ShiftY
local shiftZ = parameters.Dimensions.ShiftZ

-- Создаем цилиндр.
-- Функция CreateRightCircularCylinder(radius, height) строит цилиндр так:
--
-- 1. основание цилиндра лежит в плоскости XY;
-- 2. центр основания находится в начале координат;
-- 3. цилиндр растет вдоль положительной оси Z;
-- 4. верхняя крышка оказывается на высоте height.
--
-- Это важно запомнить, потому что цилиндр ведет себя не так, как CreateBlock.
-- У цилиндра "нижняя" часть находится в z = 0, а не симметрично вокруг нуля.
--
-- Схема без сдвига:
--
--         Z
--         ^
--         |
--         |        верхняя крышка: z = height
--         |
--         |
--         |
--         O ------ основание: z = 0
--
-- После этого мы применяем Shift(...), который двигает уже готовое тело.
local solid = CreateRightCircularCylinder(radius, height)
    :Shift(shiftX, shiftY, shiftZ)

-- Что делает Shift(...):
-- - shiftX двигает цилиндр влево/вправо;
-- - shiftY двигает цилиндр вперед/назад;
-- - shiftZ двигает цилиндр вверх/вниз.
--
-- При этом Shift не меняет:
-- - радиус;
-- - высоту;
-- - форму цилиндра.
--
-- Он меняет только положение тела в пространстве.

-- Создаем контейнер детальной геометрии.
local detailedGeometry = ModelGeometry()

-- Добавляем туда наше твердое тело.
detailedGeometry:AddSolid(solid)

-- Передаем геометрию в Renga.
Style.SetDetailedGeometry(detailedGeometry)
