import pythoncom
import win32com.client


# GUID типа объекта "Колонна" в текущем проекте Renga.
COLUMN_TYPE_ID = "{D9EE2442-E807-42FB-8FE5-9DCFE543035D}"

# GUID свойства "Марка группы".
MARK_GROUP_ID = "{BE8B433A-EE51-49DE-8189-5F6476783E22}"

# GUID свойства "Порядковый номер в группе".
ORDINAL_ID = "{02E22308-EE6E-4D47-8B87-CBF23AA97548}"


def main():
    # Инициализируем COM для текущего процесса Python.
    pythoncom.CoInitialize()

    # Подключаемся к уже открытому окну Renga.
    app = win32com.client.GetActiveObject("Renga.Application.1")
    project = app.Project
    objects = project.Model.GetObjects()

    # Сюда будем собирать колонны по значению "Марка группы".
    groups = {}

    for index in range(objects.Count):
        obj = objects.GetByIndex(index)

        # Пропускаем все, что не является колонной.
        if obj.ObjectTypeS != COLUMN_TYPE_ID:
            continue

        props = obj.GetProperties()
        mark_group = str(props.GetS(MARK_GROUP_ID).GetStringValue())

        # Сохраняем пару: Id объекта + сам объект.
        # Id нужен, чтобы внутри одной группы был стабильный порядок.
        groups.setdefault(mark_group, []).append((int(obj.Id), obj))

    # Открываем одну операцию проекта на все изменения.
    operation = project.CreateOperation()
    operation.Start()

    for mark_group in sorted(groups):
        # Внутри каждой группы нумерация начинается заново с 1.
        for number, (_, obj) in enumerate(sorted(groups[mark_group]), start=1):
            obj.GetProperties().GetS(ORDINAL_ID).SetIntegerValue(number)

    # Применяем все изменения к проекту.
    operation.Apply()


if __name__ == "__main__":
    main()
