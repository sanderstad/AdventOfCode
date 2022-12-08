$lines = get-content .\input.txt

$totalScore = 0

$losses = @("BX", "CY", "AZ")
$wins = @("AY", "BZ", "CX")
$draws = @("AX", "BY", "CZ")

foreach($line in $lines)
{
    $parts = $line -split " "
    $joined = $line -replace " ", ""

    $score = 0

    if($joined -in $draws)
    {
        $score = 3
    } elseif($joined -in $wins)
    {
        $score = 6
    } elseif($joined -in $losses)
    {
        $score = 0
    }

    switch($parts[1])
    {
        "X"
        { $score += 1
        }
        "Y"
        { $score += 2
        }
        "Z"
        { $score += 3
        }
    }

    "$joined -> $score"

    $totalScore += $score
}

"Total score: $totalScore"