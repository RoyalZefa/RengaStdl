local parameters = Style.GetParameterValues()

-- В упрощенном учебном варианте из JSON читаем только глубину Extrude.
local depth = parameters.Dimensions.Depth

-- Это тот самый несимметричный профиль.
-- Он специально взят с "перекосом", чтобы зеркальная копия была хорошо заметна.
local profilePoints = {
    Point2D(-47.4, -0.7),
    Point2D(-34.6, 0),
    Point2D(-34.5, 35.6),
    Point2D(0.1, 61.5),
    Point2D(0.2, 76),
    Point2D(-47.7, 39.7),
    Point2D(-47.4, -0.7)
}

-- Placement3D задает, как локальный 2D-профиль будет расположен в 3D.
-- Здесь:
-- Point3D(0, 0, 0)    - начало локальной системы координат
-- Vector3D(1, 0, 0)   - локальная ось Z профиля направлена вдоль мировой X
-- Vector3D(0, 1, 0)   - локальная ось X профиля направлена вдоль мировой Y
--
-- Значит Extrude будет идти вдоль мировой X.
local placement = Placement3D(
    Point3D(0, 0, 0),
    Vector3D(1, 0, 0),
    Vector3D(0, 1, 0)
)

-- По точкам строим замкнутую полилинию.
local profile = CreatePolyline2D(profilePoints)

-- Из полилинии строим исходное тело выдавливанием.
local originalSolid = Extrude(profile, ExtrusionParameters(depth), placement)

-- Зеркалирование в STDL удобно делать через отрицательный коэффициент Scale.
--
-- Общая форма такая:
-- solid:Clone():Scale(Point3D(0, 0, 0), xScale, yScale, zScale)
--
-- fixedPoint = Point3D(0, 0, 0) означает, что плоскость зеркала проходит через мировой ноль.
--
-- Готовые подстановки:
-- 1) Отражение относительно плоскости YZ:
--    Scale(Point3D(0, 0, 0), -1, 1, 1)
--    Меняется знак X.
--
-- 2) Отражение относительно плоскости XZ:
--    Scale(Point3D(0, 0, 0), 1, -1, 1)
--    Меняется знак Y.
--
-- 3) Отражение относительно плоскости XY:
--    Scale(Point3D(0, 0, 0), 1, 1, -1)
--    Меняется знак Z.
--
-- Ниже оставлен один конкретный вариант:
-- зеркалирование относительно плоскости XZ.
-- Если захотите другой вариант, просто поменяйте коэффициенты вручную.
local mirroredSolid = originalSolid:Clone():Scale(Point3D(0, 0, 0), 1, -1, 1)

-- В итоговую геометрию добавляем оба тела:
-- 1) исходное
-- 2) зеркальное
--
-- Так удобнее учиться: в Renga вы сразу видите, что именно изменилось.
local detailedGeometry = ModelGeometry()
detailedGeometry:AddSolid(originalSolid)
detailedGeometry:AddSolid(mirroredSolid)
Style.SetDetailedGeometry(detailedGeometry)
