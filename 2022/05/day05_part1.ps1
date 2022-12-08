# Import the raw data
$stacks = get-content .\input_stack.txt
$procedures = get-content .\input_procedure.txt
#$stacks = get-content .\input.txt

# Just get the stacks without the stack numbers
$stackLines = $stacks | Where-Object {-not $_.StartsWith(" 1")}

# Get the stack numbers
$stackNumbers = ($stacks[-1] -replace '\D+(\d+)','$1') -split "" | Where-Object {$_ -ne ""}

# Get the longest line
$maxLength = ($stacks | Measure-Object -Maximum -Property Length).Maximum

# Get the longest string
$longestString = ($stacks | Where-Object{$_.Length -eq $maxLength -and $_.StartsWith("[")}) | Select-Object -First 1

# Get all the positions of the stacks
$stackPositions = ($longestString | Select-String "\[" -AllMatches).Matches.Index

# Set the dummy value to fill up the empty space
$stacks
$stacksArray = @()

function Move-StackItems([array]$Sequence)
{

    $itemCount = $sequence[0]
    $stackFrom = $stacksArray | Where-Object StackNumber -eq $sequence[1]
    $stackDest = $stacksArray | Where-Object StackNumber -eq $sequence[2]

    for($i = 1; $i -le $itemCount; $i++)
    {
        # Add the create to the stack
        #$null = $stackDest.Stack.Insert($stackDest.Stack.Count, $stackFrom.Stack[($stackFrom.Stack.Count - 1)])
        $stackDest.Stack += $stackFrom.Stack[($stackFrom.Stack.Count - 1)]

        # Remove the item from the stack
        if($stackFrom.Stack.Count -eq 1)
        {
            #$null = $stackFrom.Stack.RemoveAt(0)
            $stackFrom.Stack = @()
        } else
        {
            #$null = $stackFrom.Stack.RemoveAt($stackFrom.Stack.Count - 1)
            $temp = $stackFrom.Stack[0..($stackFrom.Stack.Count - 2)]


            ($stacksArray | Where-Object StackNumber -eq $sequence[1]).Stack = $temp

        }
    }
}

# Loop through the amount of stacks
for($i = 0; $i -lt $stackNumbers.Count; $i++)
{
    # Add an object to the stacks array
    $stackObject = [PSCustomObject]@{
        StackNumber = $i + 1
        #Stack = [System.Collections.ArrayList]@()
        Stack = @()
        ItemCount = 0
    }

    # Loop through the lines
    for($j = $stackLines.Count; $j -ge 0; $j--)
    {
        $line = $stackLines[$j]

        # If the length of the line is less than the longest string
        if($line.Length -lt $maxLength)
        {
            $line += (' ' * ($maxLength - $line.Length))
        }

        $position = $stackPositions[$i]

        if($line.SubString($position, 1) -eq '[')
        {
            #$null = $stackObject.Stack.Add("$($line.Substring($position,3))")
            $stackObject.Stack += "$($line.Substring($position,3))"
        }
    }

    $stacksArray += $stackObject
}

# Loop through the procedures
$count = 1
foreach($procedure in $procedures)
{
    "Procedure [$count]: $procedure"

    # Lets seperate the actions and counts
    $procParts = $procedure -split " "

    # Set up the sequence
    $sequence = @($procParts[1], $procParts[3], $procParts[5])

    # Move the items
    Move-StackItems -Sequence $sequence

    $count++
}

$stacksArray | ForEach-Object {
    $_.ItemCount = ($_.Stack | Where-Object {$_ -ne $null}).Count
}

(($stacksArray | where-object {$_.StackNumber -eq 9}).Stack | Where-Object {$_ -ne $null}) -join ","

(($stacksArray | where-object {$_.StackNumber -eq 9}).Stack) -join ","

$stacksArray