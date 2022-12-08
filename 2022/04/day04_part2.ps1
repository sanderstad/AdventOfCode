$lines = get-content .\input.txt

$arrayRanges = @()

$totaloverlaps = 0

#Make another list of full ranges
$id = 1
foreach($line in $lines)
{
    $pairParts = $line -split ","
    $pairRanges1 = $pairParts[0] -split "-"
    $pairRanges2 = $pairParts[1] -split "-"

    $arrayRanges += [PSCustomObject]@{
        ID = $id
        Range1 = $pairRanges1[0]..$pairRanges1[1]
        Range2 = $pairRanges2[0]..$pairRanges2[1]
    }

    $id++
}

foreach($range in $arrayRanges)
{
    [bool]$overlapped = $false

    foreach($item1 in $range.Range1)
    {
        if($item1 -in $range.Range2)
        {
            $overlapped = $true
        }
    }

    foreach($item2 in $range.Range2)
    {
        if($item2 -in $range.Range1)
        {
            $overlapped = $true
        }
    }

    if($overlapped)
    {
        $range
        $totaloverlaps++
    }

}

$totaloverlaps

