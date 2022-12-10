# Import the raw data
#$lines = get-content .\input_sample.txt
$lines = get-content .\input.txt

$knotsArray = @()

for($i = 1; $i -le 10; $i++)
{
    $knotsArray += [PSCustomObject] @{
        X = 0
        Y = 0
    }
}

$countVisited = @()

$motions = @()

# Loop through the lines
foreach($line in $lines)
{
    $lineParts = $line -split " "

    $motions += [PSCustomObject]@{
        Direction = $lineParts[0]
        Distance = $lineParts[1]
    }
}

foreach ($motion in $motions)
{
    foreach ($step in 1..$($motion.Distance))
    {
        switch ($motion.Direction)
        {
            'R'
            {
                $knotsArray[0].X++
            }
            'L'
            {
                $knotsArray[0].X--
            }
            'U'
            {
                $knotsArray[0].Y++
            }
            'D'
            {
                $knotsArray[0].Y--
            }
        }

        for($i = 1; $i -le 9; $i++)
        {
            if (-not ([System.Math]::Abs($knotsArray[$i].X - $knotsArray[$i - 1].X) -in 0,1 -and [System.Math]::Abs($knotsArray[$i].Y - $knotsArray[$i - 1].Y) -in 0,1))
            {
                if (($knotsArray[$i - 1].X - $knotsArray[$i].X) -gt 0)
                {
                    $knotsArray[$i].X++
                } elseif (($knotsArray[$i - 1].X - $knotsArray[$i].X) -lt 0)
                {
                    $knotsArray[$i].X--
                }

                if (($knotsArray[$i - 1].Y - $knotsArray[$i].Y) -gt 0)
                {
                    $knotsArray[$i].Y++
                } elseif (($knotsArray[$i - 1].Y - $knotsArray[$i].Y) -lt 0)
                {
                    $knotsArray[$i].Y--
                }
            }

            if ("$($knotsArray[-1].X),$($knotsArray[-1].Y)" -notin $countVisited)
            {
                $countVisited += ,"$($knotsArray[-1].X),$($knotsArray[-1].Y)"
            }
        }
    }
}

"Visited $($countVisited.Count) places."