import pythoncom
import win32com.client


COLUMN_TYPE_ID = "{D9EE2442-E807-42FB-8FE5-9DCFE543035D}"
MARK_GROUP_ID = "{BE8B433A-EE51-49DE-8189-5F6476783E22}"
ORDINAL_ID = "{02E22308-EE6E-4D47-8B87-CBF23AA97548}"


def main():
    pythoncom.CoInitialize()
    app = win32com.client.GetActiveObject("Renga.Application.1")
    project = app.Project
    objects = project.Model.GetObjects()
    groups = {}

    for index in range(objects.Count):
        obj = objects.GetByIndex(index)
        if obj.ObjectTypeS != COLUMN_TYPE_ID:
            continue

        props = obj.GetProperties()
        mark_group = str(props.GetS(MARK_GROUP_ID).GetStringValue())
        groups.setdefault(mark_group, []).append((int(obj.Id), obj))

    operation = project.CreateOperation()
    operation.Start()

    for mark_group in sorted(groups):
        for number, (_, obj) in enumerate(sorted(groups[mark_group]), start=1):
            obj.GetProperties().GetS(ORDINAL_ID).SetIntegerValue(number)

    operation.Apply()


if __name__ == "__main__":
    main()
