# Read the worksheet
$lines = Get-Content "input.txt"

# Find the width of the worksheet
$maxWidth = ($lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum

# Pad all lines to the same width
$paddedLines = $lines | ForEach-Object { $_.PadRight($maxWidth) }

# Process column by column to identify problems
$problems = @()
$col = 0

while ($col -lt $maxWidth) {
    # Check if this column is all spaces (separator)
    $isAllSpaces = $true
    foreach ($line in $paddedLines) {
        if ($line[$col] -ne ' ') {
            $isAllSpaces = $false
            break
        }
    }

    if ($isAllSpaces) {
        $col++
        continue
    }

    # Find the extent of this problem (consecutive non-all-space columns)
    $startCol = $col
    $endCol = $col

    while ($endCol -lt $maxWidth) {
        $isColumnAllSpaces = $true
        foreach ($line in $paddedLines) {
            if ($line[$endCol] -ne ' ') {
                $isColumnAllSpaces = $false
                break
            }
        }

        if ($isColumnAllSpaces) {
            break
        }
        $endCol++
    }

    # Extract the problem from startCol to endCol-1
    $problemLines = @()
    foreach ($line in $paddedLines) {
        $problemLines += $line.Substring($startCol, $endCol - $startCol).Trim()
    }

    # Parse the problem: last line is operator, others are numbers
    $operator = $problemLines[-1]
    $numbers = @()
    for ($i = 0; $i -lt $problemLines.Count - 1; $i++) {
        if ($problemLines[$i] -ne '') {
            $numbers += [long]$problemLines[$i]
        }
    }

    # Calculate the result
    if ($operator -eq '+') {
        $result = 0
        foreach ($num in $numbers) {
            $result += $num
        }
    }
    elseif ($operator -eq '*') {
        $result = 1
        foreach ($num in $numbers) {
            $result *= $num
        }
    }

    $problems += $result
    $col = $endCol
}

# Calculate grand total
$grandTotal = 0
foreach ($answer in $problems) {
    $grandTotal += $answer
}

Write-Host "Grand total: $grandTotal"
