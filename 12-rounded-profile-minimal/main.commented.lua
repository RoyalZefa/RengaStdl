-- Этот учебный пример специально почти повторяет 08-minimal.
-- Мы сохраняем ту же форму, те же точки и ту же операцию Extrude().
-- Новый прием здесь только один:
-- скругление угла 2D-профиля через FilletCornerAfterSegment2D(...).

-- Получаем параметры из geometry.json.
local parameters = Style.GetParameterValues()

-- Читаем размеры профиля и глубину выдавливания.
local baseWidth = parameters.Dimensions.BaseWidth
local shoulderHeight = parameters.Dimensions.ShoulderHeight
local topWidth = parameters.Dimensions.TopWidth
local totalHeight = parameters.Dimensions.TotalHeight
local depth = parameters.Dimensions.Depth

-- Читаем новый параметр: радиус скругления.
local filletRadius = parameters.Dimensions.FilletRadius

-- Считаем половины ширин, чтобы построить симметричный профиль.
local halfBaseWidth = baseWidth / 2
local halfTopWidth = topWidth / 2

-- Это тот же профиль, что и в 08-minimal.
-- Сначала мы строим обычную полилинию по точкам,
-- то есть профиль еще с острыми углами.
local profilePoints = {
    Point2D(-halfBaseWidth, 0),
    Point2D(halfBaseWidth, 0),
    Point2D(halfBaseWidth, shoulderHeight),
    Point2D(halfTopWidth, totalHeight),
    Point2D(-halfTopWidth, totalHeight),
    Point2D(-halfBaseWidth, shoulderHeight),
    Point2D(-halfBaseWidth, 0)
}

-- Создаем полилинию из списка точек.
local profile = CreatePolyline2D(profilePoints)

-- Вот главный новый прием проекта.
-- FilletCornerAfterSegment2D(curve, segmentIndex, radius)
-- скругляет угол после указанного сегмента.
--
-- В нашем профиле сегменты нумеруются так:
-- сегмент 1: от точки 1 к точке 2
-- сегмент 2: от точки 2 к точке 3
-- сегмент 3: от точки 3 к точке 4
-- сегмент 4: от точки 4 к точке 5
-- сегмент 5: от точки 5 к точке 6
-- сегмент 6: от точки 6 к точке 7
--
-- Для самого простого учебного примера мы оставляем
-- фиксированное скругление после сегмента 2.
-- Это значит:
-- скругляется угол в точке 3,
-- то есть правый верхний угол прямой боковины.
--
-- Именно такой же прием используется в official_primer:
-- сначала строится полилиния,
-- потом один из углов заменяется дугой скругления.
FilletCornerAfterSegment2D(profile, 2, filletRadius)

-- Placement оставляем тем же, что и в 08-minimal,
-- чтобы новый урок был только про скругление, а не про новую ориентацию.
local placement = Placement3D(
    Point3D(0, 0, 0),
    Vector3D(0, 1, 0),
    Vector3D(1, 0, 0)
)

-- Выдавливаем уже не острый, а скругленный профиль.
local solid = Extrude(profile, ExtrusionParameters(depth), placement)

-- Создаем контейнер детальной геометрии.
local detailedGeometry = ModelGeometry()

-- Добавляем туда тело.
detailedGeometry:AddSolid(solid)

-- Передаем результат в Renga.
Style.SetDetailedGeometry(detailedGeometry)
