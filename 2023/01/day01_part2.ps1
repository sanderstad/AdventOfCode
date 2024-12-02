# Calibration document content
$calibrationDocument = @'
 two1nine
 eightwothree
 abcone2threexyz
 xtwone3four
 4nineeightseven2
 zoneight234
 7pqrstsixteen
'@

#$calibrationDocument = Get-Content -Path "$PSScriptRoot\input_part1.txt" -Raw

# Function to calculate the sum of calibration values
function CalculateCalibrationSum {
    param (
        [string]$calibrationDocument
    )

    $sum = 0

    $pattern = '(\d+|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thriteen|fouteen|fifteen|sixteen|seventeen|eightteen|nineteen|twenty|twentyone|twentytwo|twentythree|twentyfour|twentyfive|twentysix|twentyseven|twentyeight|twentynine|thirty|thirtyone|thirtytwo|thirtythree|thirtyfour|thirtyfive|thirtysix|thirtyseven|thirtyeight|thirtynine|forty|fortyone|fortytwo|fortythree|fortyfour|fortyfive|fortysix|fortyseven|fortyeight|fortynine|fifty|fiftyone|fiftytwo|fiftythree|fiftyfour|fiftyfive|fiftysix|fiftyseven|fiftyeight|fiftynine|sixty|sixtyone|sixtytwo|sixtythree|sixtyfour|sixtyfive|sixtysix|sixtyseven|sixtyeight|sixtynine|seventy|seventyone|seventytwo|seventythree|seventyfour|seventyfive|seventysix|seventyseven|seventyeight|seventynine|eighty|eightyone|eightytwo|eightythree|eightyfour|eightyfive|eightysix|eightyseven|eightyeight|eightynine|ninety|ninetyone|ninetytwo|ninetythree|ninetyfour|ninetyfive|ninetysix|ninetyseven|ninetyeight|ninetynine\b)'

    # Split the document into lines
    $lines = $calibrationDocument -split "`n"

    #$textNumbersArray = ConvertNumbersToText -start 1 -end 99

    foreach ($line in $lines) {
        #$values = $line -split $pattern | Where-Object { $_ -ne "" }
        $values = [Regex]::Matches($line, $pattern) | ForEach-Object {
            $_.Value.ToLower()
        }

        $valueArray = @()

        foreach ($value in $values) {
            if ($value -match '\d') {
                $valueArray += $value
                #$valueArray += ($_.Value -split '')
            }
            elseif ($value -in $textNumbersArray.Text) {
                $textNumber = $textNumbersArray | Where-Object { $_.Text -eq $value }
                $valueArray += $textNumber.Number
            }
        }



        # Match the first and last digits and convert to a two-digit number
        $calibrationValue = [int]("$((($valueArray[0]-split '')[0]))$((($valueArray[-1]-split '')[-1]))")
        $calibrationValue
        # Add the calibration value to the sum
        $sum += $calibrationValue
    }

    return $sum
}

function ConvertNumbersToText {
    [CmdletBinding()]
    param (
        [int]$start = 1,
        [int]$end = 100
    )

    # Define text representations for numbers
    $textNumbers = @('zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten',
        'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteclsen', 'seventeen', 'eighteen', 'nineteen')

    $tens = @('', 'ten', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety')

    # Function to convert a number to text
    function NumberToText {
        param (
            [int]$number
        )

        if ($number -lt 20) {
            $textValue = $textNumbers[$number]
            #return $textNumbers[$number]
        }

        $digit = $number % 10
        $ten = [math]::Floor($number / 10)

        $textValue = ''
        if ($digit -eq 0) {
            $textValue = $($tens[$ten])

            #return $tens[$ten]
        }
        else {
            $textValue = "$($tens[$ten])$($textNumbers[$digit])"
            #return "$($tens[$ten])$($textNumbers[$digit])"
        }

        return [PSCustomObject]@{
            Number = $number
            Text   = $textValue
        }
    }

    # Generate an array of text numbers
    $textNumbersArray = $start..$end | ForEach-Object { NumberToText -number $_ }

    return $textNumbersArray
}

# Generate text representations for numbers from 1 to 100
$textNumbersArray = ConvertNumbersToText -start 1 -end 99

# Calculate the sum and display the result
$calibrationSum = CalculateCalibrationSum -calibrationDocument $calibrationDocument


Write-Host "The sum of all calibration values is: $calibrationSum"