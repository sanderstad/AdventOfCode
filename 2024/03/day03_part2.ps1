function Calculate-MulResults {
    param (
        [string]$InputText
    )

    $pattern = "do\(\)|don't\(\)|mul\(\d+,\d+\)"  # Regex to match do(), don't(), and mul(x, y)

    # Variables to track the state
    $isEnabled = $true
    $totalSum = 0

    # Process matches in order
    $matched = [regex]::Matches($InputText, $pattern)

    Write-Host $matched.Count

    foreach ($match in $matched) {
        $instruction = $match.Groups[0].Value

        if ($instruction -eq "do()") {
            $isEnabled = $true
        }
        elseif ($instruction -eq "don't()") {
            $isEnabled = $false
        }
        elseif ($instruction -like "mul(*") {
            Write-Host "Found multiplication: $($match.Groups[0].Value) * $($match.Groups[0].Value)"

            $mulPattern = 'mul\((\d+),(\d+)\)'

            $mulMatch = [regex]::Match($instruction, $mulPattern)

            if ($isEnabled) {
                $x = [int]$mulMatch.Groups[1].Value
                $y = [int]$mulMatch.Groups[2].Value
                $totalSum += ($x * $y)
            }
        }
    }

    # Return the total sum of enabled multiplications
    return $totalSum
}

# Example input
$text = Get-Content -Path "input.txt" -Raw

# Calculate the result
$result = Calculate-MulResults -InputText $text

# Output the result
Write-Output "The total sum of enabled multiplications is: $result"