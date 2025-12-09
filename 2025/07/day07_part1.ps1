# Read the manifold diagram
$lines = Get-Content "input.txt"

# Find the starting position (S)
$startRow = -1
$startCol = -1
for ($row = 0; $row -lt $lines.Count; $row++) {
    $col = $lines[$row].IndexOf('S')
    if ($col -ge 0) {
        $startRow = $row
        $startCol = $col
        break
    }
}

# Track active beams: each beam has a row and column position
# Beams move downward until they hit a splitter or exit
$beams = @(@{row = $startRow; col = $startCol})
$splitCount = 0

# Track which splitters have been activated to avoid infinite loops
$activatedSplitters = @{}

while ($beams.Count -gt 0) {
    $newBeams = @()

    foreach ($beam in $beams) {
        # Move beam down one row
        $beam.row++

        # Check if beam exited the manifold
        if ($beam.row -ge $lines.Count) {
            continue
        }

        # Check what's at the current position
        $char = $lines[$beam.row][$beam.col]

        if ($char -eq '^') {
            # Hit a splitter
            $splitterKey = "$($beam.row),$($beam.col)"

            # Only count and split if this splitter hasn't been activated yet
            if (-not $activatedSplitters.ContainsKey($splitterKey)) {
                $activatedSplitters[$splitterKey] = $true
                $splitCount++

                # Create two new beams: left and right of the splitter
                # Left beam
                if ($beam.col -gt 0) {
                    $newBeams += @{row = $beam.row; col = $beam.col - 1}
                }

                # Right beam
                if ($beam.col -lt $lines[$beam.row].Length - 1) {
                    $newBeams += @{row = $beam.row; col = $beam.col + 1}
                }
            }
            # If already activated, this beam just stops (doesn't continue)
        }
        elseif ($char -eq '.' -or $char -eq 'S') {
            # Empty space or start position - beam continues
            $newBeams += $beam
        }
    }

    $beams = $newBeams
}

Write-Host "Total beam splits: $splitCount"
