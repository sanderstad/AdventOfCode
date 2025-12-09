# Read input
$lines = Get-Content "input.txt"

# Split into ranges and ids
$separatorIndex = $lines.IndexOf("")
$rangesLines = $lines[0..($separatorIndex - 1)]
$idsLines = $lines[($separatorIndex + 1)..($lines.Count - 1)]

# Parse ranges into start/end integers
$ranges = foreach ($line in $rangesLines) {
    $parts = $line -split "-"
    [pscustomobject]@{
        Start = [long]$parts[0]
        End   = [long]$parts[1]
    }
}

# Merge overlapping ranges to reduce checks
$merged = @()
$sortedRanges = $ranges | Sort-Object Start, End
foreach ($range in $sortedRanges) {
    if ($merged.Count -eq 0 -or $range.Start -gt $merged[-1].End + 0) {
        $merged += $range
    }
    else {
        # Extend the last merged range if overlap/adjacent
        $merged[-1].End = [Math]::Max($merged[-1].End, $range.End)
    }
}

$freshCount = 0

foreach ($idLine in $idsLines) {
    if ([string]::IsNullOrWhiteSpace($idLine)) { continue }
    $id = [long]$idLine
    $isFresh = $false

    foreach ($range in $merged) {
        if ($id -ge $range.Start -and $id -le $range.End) {
            $isFresh = $true
            break
        }
    }

    if ($isFresh) { $freshCount++ }
}

Write-Host "Fresh ingredient IDs: $freshCount"
