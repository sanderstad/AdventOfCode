# Calibration document content
<# $calibrationDocument = @'
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
'@ #>

$calibrationDocument = Get-Content -Path "$PSScriptRoot\input_part1.txt" -Raw

# Function to calculate the sum of calibration values
function CalculateCalibrationSum {
    param (
        [string]$calibrationDocument
    )

    $sum = 0

    # Split the document into lines
    $lines = $calibrationDocument -split "`n"

    foreach ($line in $lines) {
        $values = $line -split "(\D+|\d)" | Where-Object { $_ -match '\d' }

        # Match the first and last digits and convert to a two-digit number
        $calibrationValue = [int]("$($values[0])$($values[-1])")

        # Add the calibration value to the sum
        $sum += $calibrationValue
    }

    return $sum
}

# Calculate the sum and display the result
$calibrationSum = CalculateCalibrationSum -calibrationDocument $calibrationDocument
Write-Host "The sum of all calibration values is: $calibrationSum"