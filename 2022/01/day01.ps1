$lines = get-content .\input.txt

$elves = @()

$elfCount = 0

for($i = 0; $i -lt $lines.length; $i++)
{
    if($lines[$i].Length -eq 0)
    {
        $elves += [pscustomobject]@{
            Id = ($elfCount+1)
            Calories = 0
        }

        $elfCount++
    } else
    {
        $elves[$elfCount-1].Calories += $lines[$i]
    }
}

$elves | select-object -property Id, Calories | Sort-Object -property Calories -Descending | select-object -first 1

$topThree = $elves | select-object -property Id, Calories | Sort-Object -property Calories -Descending | select-object -first 3

$sum
$topThree | ForEach-Object {
    $sum += $_.Calories
}

$sum