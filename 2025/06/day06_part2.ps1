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

    # Extract the problem - read right-to-left, column by column
    # Build numbers by reading each column from right to left
    $numbers = @()

    # Last row is the operator (same for all columns in the problem)
    $operator = $paddedLines[-1].Substring($startCol, $endCol - $startCol).Trim()

    # For each column in the problem (right to left)
    for ($c = $endCol - 1; $c -ge $startCol; $c--) {
        # Read digits top to bottom in this column to form a number
        $digits = ""
        for ($row = 0; $row -lt $paddedLines.Count - 1; $row++) {
            $char = $paddedLines[$row][$c]
            if ($char -ne ' ') {
                $digits += $char
            }
        }

        if ($digits -ne '') {
            $numbers += [long]$digits
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
