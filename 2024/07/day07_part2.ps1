function Solve-CalibrationEquations {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Equations
    )

    $totalCalibrationResult = 0
    $totalEquations = $Equations.Length
    $processedEquations = 0

    foreach ($equation in $Equations) {
        # Update progress
        $processedEquations++
        $percentComplete = [math]::Floor(($processedEquations / $totalEquations) * 100)
        Write-Progress -Activity "Solving Calibration Equations" -Status "$percentComplete% Complete" -PercentComplete $percentComplete

        $parts = $equation -split ': '
        $testValue = [long]$parts[0]
        $numbers = $parts[1] -split ' ' | ForEach-Object { [int]$_ }

        $validEquation = $false

        # Try all possible operator combinations (now including concatenation)
        for ($i = 0; $i -lt ([Math]::Pow(3, $numbers.Length - 1)); $i++) {
            $operators = @()
            $currentBitmask = $i

            for ($j = 0; $j -lt $numbers.Length - 1; $j++) {
                $remainder = $currentBitmask % 3
                $operators += switch ($remainder) {
                    0 { '+' }
                    1 { '*' }
                    2 { '||' }
                }
                $currentBitmask = [Math]::Floor($currentBitmask / 3)
            }

            $expression = $numbers[0]
            for ($k = 0; $k -lt $operators.Length; $k++) {
                $expression = switch ($operators[$k]) {
                    '+' { $expression + $numbers[$k + 1] }
                    '*' { $expression * $numbers[$k + 1] }
                    '||' { [long]($expression.ToString() + $numbers[$k + 1].ToString()) }
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