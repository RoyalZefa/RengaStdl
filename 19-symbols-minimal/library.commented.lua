-- Этот файл подключается из main.lua через:
-- require("library")
--
-- Здесь лежат функции, которые создают 2D-символы.
-- Каждая функция возвращает готовый GeometrySet2D,
-- который потом можно передать в:
-- Style.SetSymbolGeometry(...)
-- или
-- Style.SetSymbolicGeometry(...)

function createRectangleSymbol(size)
    -- Создаем пустой контейнер для 2D-геометрии символа.
    local geometry = GeometrySet2D()

    -- Строим прямоугольный контур.
    -- Point2D(0, 0) = центр прямоугольника.
    -- 0 = угол поворота.
    -- size = ширина.
    -- size * 0.7 = высота.
    local contour = CreateRectangle2D(Point2D(0, 0), 0, size, size * 0.7)

    -- Добавляем саму кривую прямоугольника в набор.
    geometry:AddCurve(contour)

    -- Создаем и добавляем заливку внутри контура.
    geometry:AddMaterialColorSolidArea(FillArea(contour))

    -- Возвращаем готовый символ.
    return geometry
end

function createCircleCrossSymbol(size)
    -- Создаем пустой контейнер для 2D-геометрии символа.
    local geometry = GeometrySet2D()

    -- Радиус берем как половину общего размера символа.
    local radius = size / 2

    -- Строим окружность с центром в начале координат.
    local contour = CreateCircle2D(Point2D(0, 0), radius)

    -- Добавляем окружность в набор кривых.
    geometry:AddCurve(contour)

    -- Делаем заливку круга.
    geometry:AddMaterialColorSolidArea(FillArea(contour))

    -- Добавляем горизонтальную линию креста.
    -- Она немного короче диаметра, чтобы не выходить за край круга.
    geometry:AddCurve(CreateLineSegment2D(
        Point2D(-radius * 0.65, 0),
        Point2D(radius * 0.65, 0)
    ))

    -- Добавляем вертикальную линию креста.
    geometry:AddCurve(CreateLineSegment2D(
        Point2D(0, -radius * 0.65),
        Point2D(0, radius * 0.65)
    ))

    -- Возвращаем готовый символ.
    return geometry
end

function createDiamondSymbol(size)
    -- Создаем пустой контейнер для 2D-геометрии символа.
    local geometry = GeometrySet2D()

    -- Для ромба удобно взять "радиус" от центра до вершины.
    local radius = size / 2

    -- Строим замкнутую ломаную из пяти точек.
    -- Последняя точка повторяет первую, чтобы контур был закрыт.
    local contour = CreatePolyline2D({
        Point2D(0, radius),
        Point2D(radius, 0),
        Point2D(0, -radius),
        Point2D(-radius, 0),
        Point2D(0, radius)
    })

    -- Добавляем контур ромба.
    geometry:AddCurve(contour)

    -- Добавляем заливку внутри ромба.
    geometry:AddMaterialColorSolidArea(FillArea(contour))

    -- Возвращаем готовый символ.
    return geometry
end

function createScreenSymbol(size)
    -- Создаем пустой контейнер для 2D-геометрии символа.
    local geometry = GeometrySet2D()

    -- Внешний прямоугольник будет рамкой экрана.
    local outer = CreateRectangle2D(Point2D(0, 0), 0, size, size * 0.7)

    -- Внутренний прямоугольник будет "зоной экрана".
    local inner = CreateRectangle2D(Point2D(0, 0), 0, size * 0.72, size * 0.44)

    -- Добавляем внешний контур.
    geometry:AddCurve(outer)

    -- Добавляем внутренний контур.
    geometry:AddCurve(inner)

    -- Заливаем только внутреннюю часть,
    -- чтобы символ читался как экран внутри рамки.
    geometry:AddMaterialColorSolidArea(FillArea(inner))

    -- Возвращаем готовый символ.
    return geometry
end
