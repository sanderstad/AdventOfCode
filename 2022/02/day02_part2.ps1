$lines = get-content .\input.txt

$totalScore = 0

$losses = @("B X", "C Y", "A Z")
$wins = @("A Y", "B Z", "C X")
$draws = @("A X", "B Y", "C Z")

foreach($line in $lines)
{
    $parts = $line -split " "
    $joined = $line -replace " ", ""

    $score = 0

    if($parts[1] -eq "X")
    {
        $score = 0
        $outcome = $losses | Where-Object { $_ -like "$($parts[0])*" }
    } elseif($parts[1] -eq "Y")
    {
        $score = 3
        $outcome = $draws | Where-Object { $_ -like "$($parts[0])*" }
    } elseif($parts[1] -eq "Z")
    {
        $score = 6
        $outcome = $wins | Where-Object { $_ -like "$($parts[0])*" }
    }

    switch(($outcome -split " ")[1])
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

    "$($joined):$($outcome) -> $score"

    $totalScore += $score
}

"Total score: $totalScore"