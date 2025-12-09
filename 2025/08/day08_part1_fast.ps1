# Read junction box positions
$lines = Get-Content "input.txt"
$boxes = [System.Collections.Generic.List[int[]]]::new()

foreach ($line in $lines) {
    $coords = $line -split ","
    $boxes.Add(@([int]$coords[0], [int]$coords[1], [int]$coords[2]))
}

Write-Host "Loaded $($boxes.Count) junction boxes"
Write-Host "Calculating all distances..."

# Calculate all pairwise distances - use ArrayList for better performance
$distances = [System.Collections.ArrayList]::new()
$totalPairs = ($boxes.Count * ($boxes.Count - 1)) / 2

for ($i = 0; $i -lt $boxes.Count; $i++) {
    if ($i % 100 -eq 0) {
        $pct = [int](($i * $boxes.Count / 2.0) / $totalPairs * 100)
        Write-Host "  Progress: $pct% (box $i of $($boxes.Count))"
    }

    $b1 = $boxes[$i]
    for ($j = $i + 1; $j -lt $boxes.Count; $j++) {
        $b2 = $boxes[$j]
        $dx = $b1[0] - $b2[0]
        $dy = $b1[1] - $b2[1]
        $dz = $b1[2] - $b2[2]
        $distSq = [long]$dx * $dx + [long]$dy * $dy + [long]$dz * $dz

        [void]$distances.Add([PSCustomObject]@{ D = $distSq; I = $i; J = $j })
    }
}

Write-Host "Sorting $($distances.Count) distances..."
$distances = $distances | Sort-Object D

# Union-Find
$parent = @{}
$size = @{}
for ($i = 0; $i -lt $boxes.Count; $i++) {
    $parent[$i] = $i
    $size[$i] = 1
}

function Find-Root($x) {
    if ($parent[$x] -ne $x) {
        $parent[$x] = Find-Root $parent[$x]
    }
    return $parent[$x]
}

function Invoke-Union($x, $y) {
    $rootX = Find-Root $x
    $rootY = Find-Root $y

    if ($rootX -eq $rootY) { return $false }

    if ($size[$rootX] -lt $size[$rootY]) {
        $parent[$rootX] = $rootY
        $size[$rootY] += $size[$rootX]
    }
    else {
        $parent[$rootY] = $rootX
        $size[$rootX] += $size[$rootY]
    }
    return $true
}

Write-Host "Processing 1000 shortest pairs..."
$pairsProcessed = 0
$connectionsMade = 0
foreach ($d in $distances) {
    if ($pairsProcessed -ge 1000) { break }
    $pairsProcessed++
    if (Invoke-Union $d.I $d.J) { $connectionsMade++ }
}

Write-Host "Processed $pairsProcessed pairs, made $connectionsMade connections"

# Find circuit sizes
$circuits = @{}
for ($i = 0; $i -lt $boxes.Count; $i++) {
    $root = Find-Root $i
    if (-not $circuits.ContainsKey($root)) {
        $circuits[$root] = $size[$root]
    }
}

$topThree = $circuits.Values | Sort-Object -Descending | Select-Object -First 3
Write-Host "Number of circuits: $($circuits.Count)"
Write-Host "Top three circuit sizes: $($topThree -join ', ')"

if ($topThree.Count -ge 3) {
    $result = [long]$topThree[0] * [long]$topThree[1] * [long]$topThree[2]
    Write-Host "Product of three largest: $result"
} elseif ($topThree.Count -eq 1) {
    # Special case: if only one circuit, that means everyone is connected
    # The product would conceptually be: largest × 1 × 1 (for non-existent smaller circuits)
    Write-Host "Only one circuit of size $($topThree[0]) - all boxes are connected"
    Write-Host "Answer (if non-existent circuits count as 1): $($topThree[0])"
} else {
    Write-Host "Not enough circuits (only $($topThree.Count) circuits found)"
    Write-Host "All circuit sizes: $($circuits.Values | Sort-Object -Descending)"
}
