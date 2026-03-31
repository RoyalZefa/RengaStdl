import pythoncom
import win32com.client

pythoncom.CoInitialize()
app = win32com.client.GetActiveObject("Renga.Application.1")
project = app.Project
objects = project.Model.GetObjects()

column_type_id = "{D9EE2442-E807-42FB-8FE5-9DCFE543035D}"
mark_group_id = "{BE8B433A-EE51-49DE-8189-5F6476783E22}"
ordinal_id = "{02E22308-EE6E-4D47-8B87-CBF23AA97548}"

groups = {}

for i in range(objects.Count):
    obj = objects.GetByIndex(i)
    if obj.ObjectTypeS == column_type_id:
        mark = str(obj.GetProperties().GetS(mark_group_id).GetStringValue())
        groups.setdefault(mark, []).append((int(obj.Id), obj))

operation = project.CreateOperation()
operation.Start()

for mark in sorted(groups):
    for number, (_, obj) in enumerate(sorted(groups[mark]), start=1):
        obj.GetProperties().GetS(ordinal_id).SetIntegerValue(number)

operation.Apply()
