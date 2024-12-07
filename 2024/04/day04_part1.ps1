
# Detailed word-finding function with exact match
function Test-XmasMatch {
    param(
        $row,
        $col,
        $grid,
        $pattern)

    # Directions to search (horizontal, vertical, diagonal, backwards)
    $directions = @(
        @{dx = 1; dy = 0; name = "Horizontal Right" },
        @{dx = -1; dy = 0; name = "Horizontal Left" },
        @{dx = 0; dy = 1; name = "Vertical Down" },
        @{dx = 0; dy = -1; name = "Vertical Up" },
        @{dx = 1; dy = 1; name = "Diagonal Down-Right" },
        @{dx = -1; dy = -1; name = "Diagonal Up-Left" },
        @{dx = 1; dy = -1; name = "Diagonal Up-Right" },
        @{dx = -1; dy = 1; name = "Diagonal Down-Left" }
    )

    foreach ($direction in $directions) {
        $found = $true

        # Check each letter of the pattern
        for ($i = 0; $i -lt $pattern.Length; $i++) {
            #$checkRow = $row + $i * $direction.dy
            #$checkCol = $col + $i * $direction.dx

            "Row: $($row + $i + $direction.dy), Column: $($col + $i + $direction.dx)"
            $checkRow = $row + $i + $direction.dy
            $checkCol = $col + $i + $direction.dx

            # Check bounds
            if (($checkRow -lt 0) -or
                ($checkRow -ge $grid.Length) -or
                ($checkCol -lt 0) -or
                ($checkCol -ge $grid[0].Length)
            ) {
                $found = $false
                break
            }

            # Check if letter matches
            if ($grid[$checkRow][$checkCol] -ne $pattern[$i]) {
                $found = $false
                break
            }
        }

        # If pattern found, add to results
        if ($found) {
            return [PSCustomObject]@{
                StartRow  = $row
                StartCol  = $col
                Direction = $direction.name
                XCoord    = "Row $row, Column $col"
            }
        }
    }
}

function Find-XmasInPuzzle {
    param (
        [string[]]$Puzzle
    )

    # Conversion to character grid
    $grid = @()
    foreach ($line in $Puzzle) {
        $grid += $line.ToCharArray()

    }

    # Set the pattern to search for
    $pattern = @('X', 'M', 'A', 'S')

    # Get the dimensions of the puzzle
    $rows = $Puzzle.Length
    $cols = $Puzzle[0].Length

    # Results array
    $results = @()

    # Search through each position
    for ($row = 0; $row -lt $rows; $row++) {
        for ($col = 0; $col -lt $cols; $col++) {
            if ($grid[$row][$col] -ne $pattern[0]) {
                break
            }
            else {
                Write-Host "Found X at Row $row, Column $col"
                $results += Test-XmasMatch -row $row -col $col -grid $grid -pattern $pattern
            }

        }
    }

    return $results
}

# Example puzzle
$puzzle = Get-Content -Path "input_example.txt"

$xmasLocations = Find-XmasInPuzzle -Puzzle $puzzle

Write-Host "XMAS found at $($xmasLocations.Count) locations:"
$xmasLocations | Format-Table -AutoSize











