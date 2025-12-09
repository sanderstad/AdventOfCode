# Read junction box positions
$lines = Get-Content "input.txt"
$boxes = [System.Collections.Generic.List[int[]]]::new()

foreach ($line in $lines) {
    $coords = $line -split ","
    $boxes.Add(@([int]$coords[0], [int]$coords[1], [int]$coords[2]))
}

Write-Host "Loaded $($boxes.Count) junction boxes"
Write-Host "Calculating all distances..."

# Calculate all pairwise distances
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

        $distances.Add([PSCustomObject]@{ D = $distSq; I = $i; J = $j })
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

function Get-CircuitCount {
    $circuits = @{}
    for ($i = 0; $i -lt $boxes.Count; $i++) {
        $root = Find-Root $i
        if (-not $circuits.ContainsKey($root)) {
            $circuits[$root] = $true
        }
    }
    return $circuits.Count
}

Write-Host "Connecting pairs until all are in one circuit..."
$connectionsMade = 0
$lastConnection = $null

foreach ($d in $distances) {
    if (Invoke-Union $d.I $d.J) {
        $connectionsMade++
        $lastConnection = $d

        # Check if all are connected (only 1 circuit remains)
        $circuitCount = Get-CircuitCount
        if ($circuitCount -eq 1) {
            Write-Host "All boxes connected after $connectionsMade connections!"
            break
        }

        if ($connectionsMade % 100 -eq 0) {
            Write-Host "  Made $connectionsMade connections, $circuitCount circuits remaining"
        }
    }
}

# Get the X coordinates of the last two boxes connected
$x1 = $boxes[$lastConnection.I][0]
$x2 = $boxes[$lastConnection.J][0]
$product = $x1 * $x2

Write-Host ""
Write-Host "Last connection: Box $($lastConnection.I) at ($($boxes[$lastConnection.I][0]),$($boxes[$lastConnection.I][1]),$($boxes[$lastConnection.I][2])) <-> Box $($lastConnection.J) at ($($boxes[$lastConnection.J][0]),$($boxes[$lastConnection.J][1]),$($boxes[$lastConnection.J][2]))"
Write-Host "X coordinates: $x1 and $x2"
Write-Host "Product of X coordinates: $product"
