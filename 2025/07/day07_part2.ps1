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

# Use recursion with memorization to count timelines
$memo = @{}

function Invoke-TimelineCount {
    param($row, $col)

    # Check if we've exited the manifold
    if ($row -ge $lines.Count) {
        return 1
    }

    # Check memoization
    $key = "$row,$col"
    if ($memo.ContainsKey($key)) {
        return $memo[$key]
    }

    # Check what's at the current position
    $char = $lines[$row][$col]

    $count = 0

    if ($char -eq '^') {
        # Hit a splitter - split into two timelines

        # Left path
        if ($col -gt 0) {
            $count += Invoke-TimelineCount ($row + 1) ($col - 1)
        }

        # Right path
        if ($col -lt $lines[$row].Length - 1) {
            $count += Invoke-TimelineCount ($row + 1) ($col + 1)
        }
    }
    elseif ($char -eq '.' -or $char -eq 'S') {
        # Empty space - continue down
        $count = Invoke-TimelineCount ($row + 1) $col
    }

    $memo[$key] = $count
    return $count
}

$timelineCount = Invoke-TimelineCount $startRow $startCol

Write-Host "Total timelines: $timelineCount"
