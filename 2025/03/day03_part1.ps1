# Read input file
$inputFile = Join-Path $PSScriptRoot "input.txt"

$batteryBanks = Get-Content $inputFile

$totalJoltage = 0

foreach ($bank in $batteryBanks) {
    $maxJoltage = 0

    # Check all pairs of batteries (not necessarily consecutive)
    for ($i = 0; $i -lt $bank.Length - 1; $i++) {
        for ($j = $i + 1; $j -lt $bank.Length; $j++) {
            $twoDigitNumber = [int]($bank[$i] + $bank[$j])
            if ($twoDigitNumber -gt $maxJoltage) {
                $maxJoltage = $twoDigitNumber
            }
        }
    }

    Write-Host "Bank: $bank -> Max Joltage: $maxJoltage"
    $totalJoltage += $maxJoltage
}

Write-Host ""
Write-Host "Total Output Joltage: $totalJoltage" -ForegroundColor Green