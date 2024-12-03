function Read-Input {
    param (
        [string]$FilePath
    )
    $lines = Get-Content -Path $FilePath | ForEach-Object { $_.Trim() }
    $lines | ForEach-Object {
        [regex]::Matches($_, '\d+') | ForEach-Object { [int]$_.Value }
    }
}

function Is-Safe1 {
    param (
        [int[]]$Levels
    )
    for ($i = 0; $i -lt $Levels.Length - 1; $i++) {
        if (-not (1 -le [math]::Abs($Levels[$i] - $Levels[$i + 1]) -and [math]::Abs($Levels[$i] - $Levels[$i + 1]) -le 3)) {
            return $false
        }
    }
    $sortedAscending = $Levels | Sort-Object
    $sortedDescending = $sortedAscending | Sort-Object -Descending
    return ($Levels -eq $sortedAscending -or $Levels -eq $sortedDescending)
}

function Is-Safe2 {
    param (
        [int[]]$Levels
    )
    for ($i = 0; $i -lt $Levels.Length; $i++) {
        $newLevels = $Levels[0..($i - 1)] + $Levels[($i + 1)..($Levels.Length - 1)]
        if (Is-Safe1 -Levels $newLevels) {
            return $true
        }
    }
    return $false
}

# Inputbestand lezen
$inputFile = "input_part1.txt"
$numberSets = Read-Input -FilePath $inputFile

# Deel 1
$part1Result = $numberSets | Where-Object { Is-Safe1 -Levels $_ } | Measure-Object | Select-Object -ExpandProperty Count
Write-Output "Deel 1 Resultaat: $part1Result"

# Deel 2
$part2Result = $numberSets | Where-Object { Is-Safe2 -Levels $_ } | Measure-Object | Select-Object -ExpandProperty Count
Write-Output "Deel 2 Resultaat: $part2Result"