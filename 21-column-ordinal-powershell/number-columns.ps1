$ErrorActionPreference = 'Stop'

$columnTypeId = '{D9EE2442-E807-42FB-8FE5-9DCFE543035D}'
$markGroupId = '{BE8B433A-EE51-49DE-8189-5F6476783E22}'
$ordinalId = '{02E22308-EE6E-4D47-8B87-CBF23AA97548}'

$app = [System.Runtime.InteropServices.Marshal]::GetActiveObject('Renga.Application.1')
$project = $app.Project
$objects = $project.Model.GetObjects()
$groups = @{}

for ($i = 0; $i -lt $objects.Count; $i++) {
    $object = $objects.GetByIndex($i)
    if ($object.ObjectTypeS -ne $columnTypeId) {
        continue
    }

    $props = $object.GetProperties()
    $markGroup = [string]$props.GetS($markGroupId).GetStringValue()

    if (-not $groups.ContainsKey($markGroup)) {
        $groups[$markGroup] = New-Object System.Collections.ArrayList
    }

    [void]$groups[$markGroup].Add([pscustomobject]@{
        Id = [int]$object.Id
        Object = $object
    })
}

$operation = $project.CreateOperation()
$operation.Start()

foreach ($markGroup in ($groups.Keys | Sort-Object)) {
    $number = 1
    foreach ($item in ($groups[$markGroup] | Sort-Object Id)) {
        $item.Object.GetProperties().GetS($ordinalId).SetIntegerValue($number)
        $number++
    }
}

$operation.Apply()
