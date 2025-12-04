# Read the input file
$content = Get-Content "input_real.txt"

# Convert to 2D array of characters
$grid = @()
foreach ($line in $content) {
    $grid += , @($line.ToCharArray())
}

$rows = $grid.Count
$cols = $grid[0].Count

# Define the 8 adjacent positions (offsets)
$adjacentOffsets = @(
    @(-1, -1), @(-1, 0), @(-1, 1),
    @(0, -1), @(0, 1),
    @(1, -1), @(1, 0), @(1, 1)
)

$totalRemoved = 0

# Keep removing rolls until none are accessible
while ($true) {
    $accessibleInRound = 0

    # Check each position in the grid
    for ($row = 0; $row -lt $rows; $row++) {
        for ($col = 0; $col -lt $cols; $col++) {
            # Only consider rolls of paper (@)
            if ($grid[$row][$col] -eq '@') {
                # Count adjacent rolls
                $adjacentRolls = 0

                foreach ($offset in $adjacentOffsets) {
                    $newRow = $row + $offset[0]
                    $newCol = $col + $offset[1]

                    # Check if the adjacent position is within bounds
                    if ($newRow -ge 0 -and $newRow -lt $rows -and $newCol -ge 0 -and $newCol -lt $cols) {
                        if ($grid[$newRow][$newCol] -eq '@') {
                            $adjacentRolls++
                        }
                    }
                }

                # A roll is accessible if fewer than 4 rolls are adjacent
                if ($adjacentRolls -lt 4) {
                    # Remove this roll
                    $grid[$row][$col] = '.'
                    $accessibleInRound++
                }
            }
        }
    }

    $totalRemoved += $accessibleInRound

    # If no accessible rolls were found, we're done
    if ($accessibleInRound -eq 0) {
        break
    }
}

Write-Host "Total rolls removed: $totalRemoved"
