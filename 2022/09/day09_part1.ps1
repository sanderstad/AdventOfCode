# Import the raw data
#$lines = get-content .\input_sample.txt
$lines = get-content .\input.txt

$hPos = [PSCustomObject] @{
    X = 0
    Y = 0
}

$tPos = [PSCustomObject] @{
    X = 0
    Y = 0
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
                $hPos.X++
            }
            'L'
            {
                $hPos.X--
            }
            'U'
            {
                $hPos.Y++
            }
            'D'
            {
                $hPos.Y--
            }
        }

        if (([System.Math]::Abs($tPos.X - $hPos.X) -in 0,1) -and ([System.Math]::Abs($tPos.Y - $hPos.Y) -in 0,1))
        {

        } else
        {
            if ($tPos.Y -eq $hPos.Y)
            {
                switch ($motion.Direction)
                {
                    'R'
                    {
                        $tPos.X++
                    }
                    'L'
                    {
                        $tPos.X--
                    }
                }
            } elseif ($tPos.X -eq $hPos.X)
            {
                switch ($motion.Direction)
                {
                    'U'
                    {
                        $tPos.Y++
                    }
                    'D'
                    {
                        $tPos.Y--
                    }
                }
            } else
            {
                if (($hPos.X - $tPos.X) -gt 0)
                {
                    $tPos.X++
                } else
                {
                    $tPos.X--
                }

                if (($hPos.Y - $tPos.Y) -gt 0)
                {
                    $tPos.Y++
                } else
                {
                    $tPos.Y--
                }
            }
        }

        if ("$($tPos.X),$($tPos.Y)" -notin $countVisited)
        {
            $countVisited += "$($tPos.X),$($tPos.Y)"
        }
    }
}

"Visited $($countVisited.Count) places."
