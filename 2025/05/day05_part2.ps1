# Read input
$lines = Get-Content "input.txt"

# Split into ranges and ids
$separatorIndex = $lines.IndexOf("")
$rangesLines = $lines[0..($separatorIndex - 1)]

# Parse ranges into start/end integers
$ranges = foreach ($line in $rangesLines) {
    $parts = $line -split "-"
    [pscustomobject]@{
        Start = [long]$parts[0]
        End   = [long]$parts[1]
    }
}

# Merge overlapping/adjacent ranges
$merged = @()
$sortedRanges = $ranges | Sort-Object Start, End
foreach ($range in $sortedRanges) {
    if ($merged.Count -eq 0 -or $range.Start -gt $merged[-1].End + 1) {
        $merged += $range
    }
    else {
        # Extend the last merged range if overlap/adjacent
        $merged[-1].End = [Math]::Max($merged[-1].End, $range.End)
    }
}

# Count all IDs covered by merged ranges
$totalFresh = 0
foreach ($range in $merged) {
    $totalFresh += ($range.End - $range.Start + 1)
}

Write-Host "Total fresh ingredient IDs: $totalFresh"
