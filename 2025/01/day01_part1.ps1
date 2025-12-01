# Advent of Code 2025 - Day 1: Secret Entrance - Part 1
# Count how many times the dial points at 0 after any rotation

# Read input file
$inputFile = Join-Path $PSScriptRoot "input.txt"
$rotations = Get-Content $inputFile

# Initialize dial position
$dialPosition = 50
$zeroCount = 0

# Process each rotation
foreach ($rotation in $rotations) {
    # Parse the rotation: L/R and distance
    $direction = $rotation.Substring(0, 1)
    $distance = [int]$rotation.Substring(1)

    # Apply the rotation
    if ($direction -eq 'L') {
        # Left rotation (toward lower numbers)
        $dialPosition = ($dialPosition - $distance) % 100
        if ($dialPosition -lt 0) {
            $dialPosition += 100
        }
    }
    elseif ($direction -eq 'R') {
        # Right rotation (toward higher numbers)
        $dialPosition = ($dialPosition + $distance) % 100
    }

    # Debug output (optional - uncomment to see each step)
    # Write-Host "After $rotation : dial at $dialPosition"

    # Check if dial is pointing at 0
    if ($dialPosition -eq 0) {
        $zeroCount++
    }
}

# Output the result
Write-Host "The dial pointed at 0 a total of $zeroCount times."
Write-Host "The password is: $zeroCount"
