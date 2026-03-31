$ErrorActionPreference = 'Stop'

# GUID of the Column object type in the current Renga project.
# We got it from the opened model through Renga API.
$columnTypeId = '{D9EE2442-E807-42FB-8FE5-9DCFE543035D}'

# GUID of the property "Марка группы".
# We got it from PropertyManager in the current project.
$markGroupId = '{BE8B433A-EE51-49DE-8189-5F6476783E22}'

# GUID of the property "Порядковый номер в группе".
# This is the property where the script writes numbering.
$ordinalId = '{02E22308-EE6E-4D47-8B87-CBF23AA97548}'

# Connect to the already opened Renga window.
$app = [System.Runtime.InteropServices.Marshal]::GetActiveObject('Renga.Application.1')
$project = $app.Project
$objects = $project.Model.GetObjects()

# Here we will collect columns by "Марка группы".
$groups = @{}

for ($i = 0; $i -lt $objects.Count; $i++) {
    $object = $objects.GetByIndex($i)

    # Skip everything except columns.
    if ($object.ObjectTypeS -ne $columnTypeId) {
        continue
    }

    $props = $object.GetProperties()
    $markGroup = [string]$props.GetS($markGroupId).GetStringValue()

    # Create a new group if we see this mark for the first time.
    if (-not $groups.ContainsKey($markGroup)) {
        $groups[$markGroup] = New-Object System.Collections.ArrayList
    }

    # Save the object and its Id.
    # Id is used to keep stable order inside one group.
    [void]$groups[$markGroup].Add([pscustomobject]@{
        Id = [int]$object.Id
        Object = $object
    })
}

# Start one project operation for all changes.
$operation = $project.CreateOperation()
$operation.Start()

foreach ($markGroup in ($groups.Keys | Sort-Object)) {
    # Each group starts numbering from 1.
    $number = 1

    foreach ($item in ($groups[$markGroup] | Sort-Object Id)) {
        $item.Object.GetProperties().GetS($ordinalId).SetIntegerValue($number)
        $number++
    }
}

# Apply all changes to the project.
$operation.Apply()
