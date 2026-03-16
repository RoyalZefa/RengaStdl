--[[
Подробный разбор учебного файла `main.lua` из проекта `01-stdl-lesson-01`.

Это максимально простой пример STDL:
- есть параметры размеров;
- есть 3D-коробка;
- есть 2D-символ сверху.

Файл создан для обучения.
Рабочая сборка по-прежнему использует обычный `main.lua`.
]]

-- Как читать этот файл:
-- `Типовой паттерн STDL из документации Renga`:
-- `Style.GetParameterValues()`, `ModelGeometry()`, `CreateBlock(...)`,
-- `Style.SetDetailedGeometry(...)`, `GeometrySet2D()`, `Placement3D(...)`,
-- `Style.SetSymbolicGeometry(...)`.
-- `Наша логика проекта`:
-- объект `TutorialBox`, три размера `Width/Depth/Height` и прямоугольный символ сверху.
-- Здесь почти весь код специально оставлен максимально близким к базовым примерам STDL,
-- чтобы было проще увидеть скелет любого простого шаблона.

-- Получаем все значения параметров из `parameters.json`.
-- После этого у нас появляется объект `parameters`,
-- внутри которого есть группа `Dimensions`.
local parameters = Style.GetParameterValues()

-- Читаем параметры размеров.
-- Эти имена должны точно совпадать с тем, что объявлено в JSON.
local width = parameters.Dimensions.Width
local depth = parameters.Dimensions.Depth
local height = parameters.Dimensions.Height

-- Пишем значения в лог.
-- Это полезно для отладки:
-- можно быстро понять, какие размеры реально пришли в скрипт.
print("TutorialBox:", width, depth, height)

-- Функция создает 2D-символ для вида сверху.
--
-- Здесь символ очень простой:
-- обычный прямоугольник размером Width x Depth.
local function makeTopViewSymbol()
    -- Создаем контейнер для 2D-геометрии.
    local geometrySet = GeometrySet2D()

    -- Создаем прямоугольник с центром в точке (0, 0).
    local rectangle = CreateRectangle2D(Point2D(0, 0), 0, width, depth)

    -- Добавляем прямоугольник в набор.
    geometrySet:AddCurve(rectangle)

    -- Возвращаем готовую 2D-геометрию.
    return geometrySet
end

-- Создаем контейнер для основной 3D-геометрии.
local detailedGeometry = ModelGeometry()

-- Добавляем в него простое твердое тело:
-- параллелепипед с заданными шириной, глубиной и высотой.
detailedGeometry:AddSolid(CreateBlock(width, depth, height))

-- Передаем эту геометрию в Renga как детальную 3D-модель объекта.
Style.SetDetailedGeometry(detailedGeometry)

-- Создаем контейнер для условной геометрии.
local symbolicGeometry = ModelGeometry()

-- Определяем, где в 3D-пространстве будет лежать 2D-символ.
--
-- Мы ставим его на верхнюю грань блока:
-- точка по Z находится на высоте `height`.
-- Вектор Z смотрит вверх.
-- Вектор X смотрит вдоль оси X.
local topViewPlacement = Placement3D(
    Point3D(0, 0, height),
    Vector3D(0, 0, 1),
    Vector3D(1, 0, 0)
)

-- Добавляем 2D-символ в условную геометрию с нужным размещением.
symbolicGeometry:AddGeometrySet2D(makeTopViewSymbol(), topViewPlacement)

-- Передаем условную геометрию в Renga.
Style.SetSymbolicGeometry(symbolicGeometry)
