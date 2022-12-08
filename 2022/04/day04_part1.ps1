$lines = get-content .\input.txt

$pairCounter = 0

foreach($line in $lines)
{
    $pairParts = $line -split ","

    $pairRanges1 = $pairParts[0] -split "-"
    $pairRanges2 = $pairParts[1] -split "-"

    if($pairRanges1[0] -in $pairRanges2[0]..$pairRanges2[1] -and $pairRanges1[1] -in $pairRanges2[0]..$pairRanges2[1])
    {
        $pairCounter++
        $line
    } else
    {
        if($pairRanges2[0] -in $pairRanges1[0]..$pairRanges1[1] -and $pairRanges2[1] -in $pairRanges1[0]..$pairRanges1[1])
        {
            $pairCounter++
        }
    }
}

$pairCounter