function createRectangleSymbol(size)
    local geometry = GeometrySet2D()
    local contour = CreateRectangle2D(Point2D(0, 0), 0, size, size * 0.7)
    geometry:AddCurve(contour)
    geometry:AddMaterialColorSolidArea(FillArea(contour))
    return geometry
end

function createCircleCrossSymbol(size)
    local geometry = GeometrySet2D()
    local radius = size / 2
    local contour = CreateCircle2D(Point2D(0, 0), radius)
    geometry:AddCurve(contour)
    geometry:AddMaterialColorSolidArea(FillArea(contour))
    geometry:AddCurve(CreateLineSegment2D(Point2D(-radius * 0.65, 0), Point2D(radius * 0.65, 0)))
    geometry:AddCurve(CreateLineSegment2D(Point2D(0, -radius * 0.65), Point2D(0, radius * 0.65)))
    return geometry
end

function createDiamondSymbol(size)
    local geometry = GeometrySet2D()
    local radius = size / 2
    local contour = CreatePolyline2D({
        Point2D(0, radius),
        Point2D(radius, 0),
        Point2D(0, -radius),
        Point2D(-radius, 0),
        Point2D(0, radius)
    })
    geometry:AddCurve(contour)
    geometry:AddMaterialColorSolidArea(FillArea(contour))
    return geometry
end

function createScreenSymbol(size)
    local geometry = GeometrySet2D()
    local outer = CreateRectangle2D(Point2D(0, 0), 0, size, size * 0.7)
    local inner = CreateRectangle2D(Point2D(0, 0), 0, size * 0.72, size * 0.44)
    geometry:AddCurve(outer)
    geometry:AddCurve(inner)
    geometry:AddMaterialColorSolidArea(FillArea(inner))
    return geometry
end
