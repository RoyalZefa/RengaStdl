import pythoncom
import win32com.client

pythoncom.CoInitialize()
app = win32com.client.GetActiveObject("Renga.Application.1")
project = app.Project
objects = project.Model.GetObjects()

column_type_id = "{D9EE2442-E807-42FB-8FE5-9DCFE543035D}"
mark_group_id = "{be8b433a-ee51-49de-8189-5f6476783e22}"
ordinal_id = "{02e22308-ee6e-4d47-8b87-cbf23aa97548}"

groups = {}

for i in range(objects.Count):
    obj = objects.GetByIndex(i)
    if str(obj.ObjectTypeS).lower() == column_type_id.lower():
        mark = str(obj.GetProperties().GetS(mark_group_id).GetStringValue())
        groups.setdefault(mark, []).append((int(obj.Id), obj))

operation = project.CreateOperation()
operation.Start()

for mark in sorted(groups):
    for number, (_, obj) in enumerate(sorted(groups[mark]), start=1):
        obj.GetProperties().GetS(ordinal_id).SetIntegerValue(number)

operation.Apply()
