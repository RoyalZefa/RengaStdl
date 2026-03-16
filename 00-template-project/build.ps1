$builder = Join-Path $PSScriptRoot "..\RengaSTDLSDK\RstBuilder\RstBuilder.exe"
$config = Join-Path $PSScriptRoot "parameters.json"
$script = Join-Path $PSScriptRoot "main.lua"
$output = Join-Path $PSScriptRoot "new-style-template.rst"

& $builder $config $script -s 1.0 -o $output
