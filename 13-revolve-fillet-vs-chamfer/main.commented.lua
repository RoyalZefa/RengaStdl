-- Этот проект показывает надежный способ получить тело с прямой фаской.
-- Мы не используем здесь Revolve(...), потому что для первого учебного примера
-- в Renga проще и стабильнее собрать форму из двух понятных частей.
--
-- Идея очень простая:
-- 1. строим нижний цилиндр;
-- 2. строим верхнюю усеченную часть через Loft(...);
-- 3. объединяем их в одно тело через Unite(...).
--
-- В этом упрощенном варианте строится только один объект:
-- тело вращения с прямой фаской.

-- Получаем параметры из geometry.json.
local parameters = Style.GetParameterValues()

-- Радиус и высота тела.
local radius = parameters.Dimensions.Radius
local height = parameters.Dimensions.Height

-- Размер прямой фаски.
-- math.min(...) нужен как защита:
-- если студент введет слишком большое значение,
-- фаска не должна стать больше самого радиуса или высоты тела.
local straightChamfer = math.min(parameters.Dimensions.StraightChamfer, radius * 0.95, height * 0.95)

-- Это высота цилиндрической части без фаски.
local bodyHeight = height - straightChamfer

-- Сначала строим обычный цилиндр.
-- Он дает нам основное тело без верхней наклонной части.
local body = CreateRightCircularCylinder(radius, bodyHeight)

-- Теперь готовим два круглых сечения для Loft(...):
-- нижнее сечение — радиус полный,
-- верхнее сечение — радиус уменьшенный.
--
-- Между ними получится прямая наклонная поверхность,
-- то есть та самая фаска.
local bottomProfile = CreateCircle2D(Point2D(0, 0), radius)
local topProfile = CreateCircle2D(Point2D(0, 0), radius - straightChamfer)

-- Каждому сечению нужна своя локальная система координат.
-- Оба круга лежат в плоскостях XY,
-- а различаются только высотой по Z.
local placements = {
    Placement3D(Point3D(0, 0, bodyHeight), Vector3D(0, 0, 1), Vector3D(1, 0, 0)),
    Placement3D(Point3D(0, 0, height), Vector3D(0, 0, 1), Vector3D(1, 0, 0))
}

-- Loft строит тело между двумя сечениями.
-- В нашем случае это короткая верхняя усеченная часть.
local chamferPart = Loft({bottomProfile, topProfile}, placements, LoftParameters())

-- Unite объединяет цилиндрическую часть и фаску в одно твердое тело.
local solid = Unite({body, chamferPart})

-- Добавляем тело в модель.
local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(solid)
Style.SetDetailedGeometry(detailedGeometry)
