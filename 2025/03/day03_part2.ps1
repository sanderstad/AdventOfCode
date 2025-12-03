# Read input file
$inputFile = Join-Path $PSScriptRoot "input.txt"

$batteryBanks = Get-Content $inputFile

$totalJoltage = [bigint]0

foreach ($bank in $batteryBanks) {
    # We need to select exactly 12 batteries
    # Strategy: Remove (length - 12) digits to maximize the result
    # Use a greedy algorithm with a stack

    $batteriesNeeded = 12
    $batteriesToRemove = $bank.Length - $batteriesNeeded

    # Use a stack-based greedy algorithm
    $stack = New-Object System.Collections.ArrayList
    $toRemove = $batteriesToRemove

    for ($i = 0; $i -lt $bank.Length; $i++) {
        $currentDigit = $bank[$i]

        # Remove smaller digits from stack if current is larger and we need to remove more
        while ($stack.Count -gt 0 -and $toRemove -gt 0 -and $stack[$stack.Count - 1] -lt $currentDigit) {
            $stack.RemoveAt($stack.Count - 1)
            $toRemove--
        }

        [void]$stack.Add($currentDigit)
    }

    # If we still need to remove digits, remove from the end
    while ($toRemove -gt 0) {
        $stack.RemoveAt($stack.Count - 1)
        $toRemove--
    }

    $result = -join $stack
    $joltage = [bigint]$result
    Write-Host "Bank: $bank -> Max Joltage: $joltage"
    $totalJoltage += $joltage
}

Write-Host ""
Write-Host "Total Output Joltage: $totalJoltage" -ForegroundColor Green
