# Advent of Code 2025 - Day 1: Secret Entrance - Part 2
# Count how many times the dial points at 0 during AND after rotations (method 0x434C49434B)

# Read input file
$inputFile = if ($args.Count -gt 0) { Join-Path $PSScriptRoot $args[0] } else { Join-Path $PSScriptRoot "input.txt" }
$rotations = Get-Content $inputFile

# Initialize dial position
$dialPosition = 50
$zeroCount = 0

# Process each rotation
foreach ($rotation in $rotations) {
    # Parse the rotation: L/R and distance
    $direction = $rotation.Substring(0, 1)
    $distance = [int]$rotation.Substring(1)

    $startPosition = $dialPosition

    # Count how many times we click on 0 during this rotation (including the final position)
    if ($direction -eq 'L') {
        # Left rotation (toward lower numbers)
        # Calculate end position
        $endPosition = ($startPosition - $distance) % 100
        if ($endPosition -lt 0) { $endPosition += 100 }

        # Going left: hit 0 after startPosition clicks (unless already at 0)
        if ($startPosition -eq 0) {
            $zeroCount += [Math]::Floor($distance / 100)
        }
        else {
            if ($distance -ge $startPosition) {
                $zeroCount += 1 + [Math]::Floor(($distance - $startPosition) / 100)
            }
        }

        $dialPosition = $endPosition
    }
    elseif ($direction -eq 'R') {
        # Right rotation (toward higher numbers)
        # Calculate end position
        $endPosition = ($startPosition + $distance) % 100

        # Going right: hit 0 after (100 - startPosition) clicks (unless already at 0)
        if ($startPosition -eq 0) {
            $zeroCount += [Math]::Floor($distance / 100)
        }
        else {
            $clicksTo0 = 100 - $startPosition
            if ($distance -ge $clicksTo0) {
                $zeroCount += 1 + [Math]::Floor(($distance - $clicksTo0) / 100)
            }
        }

        $dialPosition = $endPosition
    }

    # Debug output (optional - uncomment to see each step)
    # Write-Host "After $rotation : dial at $dialPosition, total zeros: $zeroCount"
}

# Output the result
Write-Host "The dial pointed at 0 a total of $zeroCount times (including during rotations)."
Write-Host "The password is: $zeroCount"
