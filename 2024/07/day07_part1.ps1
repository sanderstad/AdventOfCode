function Solve-CalibrationEquations {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Equations
    )

    $totalCalibrationResult = 0

    foreach ($equation in $Equations) {
        $parts = $equation -split ': '
        $testValue = [long]$parts[0]
        $numbers = $parts[1] -split ' ' | ForEach-Object { [int]$_ }

        $validEquation = $false

        # Try all possible operator combinations
        for ($i = 0; $i -lt ([Math]::Pow(2, $numbers.Length - 1)); $i++) {
            $operators = @()
            $currentBitmask = $i

            for ($j = 0; $j -lt $numbers.Length - 1; $j++) {
                $operators += if ($currentBitmask -band 1) { '*' } else { '+' }
                $currentBitmask = $currentBitmask -shr 1
            }

            $expression = $numbers[0]
            for ($k = 0; $k -lt $operators.Length; $k++) {
                $expression = if ($operators[$k] -eq '+') {
                    $expression + $numbers[$k + 1]
                }
                else {
                    $expression * $numbers[$k + 1]
                }
            }

            if ($expression -eq $testValue) {
                $validEquation = $true
                break
            }
        }

        if ($validEquation) {
            $totalCalibrationResult += $testValue
        }
    }

    return $totalCalibrationResult
}

# Example usage
# $inputData = @"
# 190: 10 19
# 3267: 81 40 27
# 83: 17 5
# 156: 15 6
# 7290: 6 8 6 15
# 161011: 16 10 13
# 192: 17 8 14
# 21037: 9 7 18 13
# 292: 11 6 16 20
# "@ -split "`r`n"

$inputData = Get-Content -Path "input.txt"
#$inputData = Get-Content -Path "input_example.txt"

$result = Solve-CalibrationEquations -Equations $inputData
Write-Host "Total Calibration Result: $result"