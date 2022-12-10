# Import the raw data
$lines = get-content input.txt
#$lines = get-content .\input.txt
$lines = $lines | WHere-Object { $_.Length -gt 0 -and $_ -ne ""}

$cycleCount = 1

[int]$currentSignalStrength = 1

$signalStrength = [PSCustomObject]@{
    Cycle = $cycleCount
    Value = $currentSignalStrength
}

[array]$signalStrengths = @($signalStrength)



# Calculate the number of cylces in total
foreach($line in $lines)
{
    $lineParts = $line -split " "

    if($lineParts[0] -eq "addx")
    {
        $currentSignalStrength += $lineParts[1]

        $signalStrengths += [PSCustomObject]@{
            Cycle = $cycleCount
            Value = $currentSignalStrength
        }
    } else
    {
        $signalStrengths += [PSCustomObject]@{
            Cycle = $cycleCount
            Value = $currentSignalStrength
        }
    }

    $cycleCount++
}


$signalStrengths | WHere-Object { $_.Cycle -in 20, 60, 100, 140, 180, 220 } | Measure-Object -Property Value -Sum | Select-Object -ExpandProperty Sum

"Total signal strength: $currentSignalStrength"

for($i = 1; $i -le 6; $i++)
{
    $line = ''

    for($j = 1; $j -le 40; $j++)
    {
        $cycle = ($i * 40) + $j

        if([System.Math]::Abs($j - $signalStrengths[($cycle + 1)].Value) -le 1)
        {
            $line += '.'
        } else
        {
            $line += ' '
        }
    }

    $line
}

