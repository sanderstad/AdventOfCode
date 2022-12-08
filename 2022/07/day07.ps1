# Import the raw data
$lines = get-content .\input_sample.txt
#$lines = get-content .\input.txt

$path = @{}
$sums = @{}

[System.Collections.ArrayList]$current = @()

$count = 0

# Searcher function
function Search-Path
{
    param(
        [string]$key
    )

    if($path[$key].Length -gt 0)
    {
        foreach($item in $path[$key])
        {
            Search-Path -key $item

        }
    }

    $count += $sums[$key]

    return $count
}


# Loop through the lines to firgure out the paths
foreach($line in $lines)
{
    $lineParts = $line -split " "

    if($lineParts[1] -eq 'cd')
    {
        if($lineParts[2] -eq '..')
        {
            $null = $current.Remove($current)
        } else
        {
            $null = $current.Add("$($lineParts[2])")
            $null = $path.Add("$($current -join '')", @())
            $null = $sums.Add("$($current -join '')", 0)
            $count = 0
        }
    } elseif($lineParts[1] -eq 'ls')
    {
        continue
    } elseif($lineParts[0] -eq 'dir')
    {
        $path[($current -join '')] += $lineParts[1]
    } else
    {
        $sums[($current -join '')] += [int]$lineParts[0]
    }
}

$totalSizes = @{}

foreach($key in $path.Keys)
{
    $totalSizes[$key] = 0
}

foreach($p in $path.Keys)
{
    $values = @()
    $values = Search-Path -key $p
    $totalSizes[$p] += ($values | Measure-Object -Sum).Sum
}

$result = 0
foreach($item in $totalSizes)
{
    if($item.Value -le 100000)
    {
        $result += $item.Value
    }
}

$result

$usedSpace = ($sums.Value | Measure-Object -Sum).Sum
$discSpace = 70000000
$unusedSpace = 30000000
$value = $discSpace

foreach($item in $totalSizes)
{
    if(($usedSpace - $totalSize[$item]) -le ($disc_space - $unusedSpace) -and $totalSize[$item] -lt $value)
    {
        $value = $totalSize[$item]
    }
}


"Part one: $result | Part two: $value"
