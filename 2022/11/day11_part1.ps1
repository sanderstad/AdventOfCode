# Import the raw data
$lines = get-content .\input_sample.txt
#$lines = get-content .\input.txt

#$monkeyLines = $lines -split '(?:\r?\n){2,}'

[Monkey[]]$monkeys = $null

class Monkey
{
    [int]$Number
    [System.Collections.ArrayList]$StartingItems
    [string]$Operation
    [string]$Test
    [int]$TestTrue
    [int]$TestFalse

    Monkey()
    {
        $this.StartingItems = New-Object System.Collections.ArrayList
    }

    Monkey([int]$number, [int[]]$startingItems, [string]$operation, [string]$test, [int]$testTrue, [int]$testFalse)
    {
        $this.Number = $number
        $this.StartingItems = New-Object System.Collections.ArrayList
        $this.StartingItems.AddRange($startingItems)
        $this.Operation = $operation
        $this.Test = $test
        $this.TestTrue = $testTrue
        $this.TestFalse = $testFalse
    }

    [int]GetNextItem()
    {
        if($this.StartingItems.Count -eq 0)
        {
            return -1
        } else
        {
            return $this.StartingItems[0]
        }
    }

    [int]GetMonkeyToSendTo()
    {
        $item = $this.GetNextItem()

        if($item -eq -1)
        {
            return $item
        } else
        {
            if((($this.Operation -replace "old", "$item") | Invoke-Expression) % $this.Test -eq 0)
            {
                return $this.TestTrue
            } else
            {
                return $this.TestFalse
            }
        }
    }

    [void]AddItem([int[]]$items)
    {
        foreach($item in $items)
        {
            $this.StartingItems.Add([int]$item)
        }
    }

    [void]RemoveItem([int[]]$items)
    {
        foreach($item in $items)
        {
            $this.StartingItems.Remove([int]$item)
        }
    }

    [void]RemoveItemAt($index)
    {
        $this.StartingItems.RemoveAt($index)
    }

}

function Send-ItemsToMonkey
{
    param(
        [int]$from,
        [int]$to,
        [int[]]$items
    )

    foreach($item in $items)
    {
        $monkeys[$to].AddItem($item)
        $monkeys[$from].RemoveItemAt(0)
    }
}



function ConvertTo-Monkey
{
    [cmdletbinding()]
    param(
        [string[]]$MonkeyLines
    )

    # Array to hold the monkeys
    $monkeys = @()

    # Create the variables that will hold the data for parsing
    $ids, $items, $operation, $test, $testTrue, $testFalse = @(), @(), @(), @(), @(), @()

    # Pointer to keep track of the monkey number
    $currentMonkeyNumber = $null

    for($i = 0; $i -lt $monkeyLines.Length;$i++)
    {
        [string]$line = $monkeyLines[$i].Trim()

        # Monkey 0:
        # Starting items: 79, 98
        # Operation: new = old * 19
        # Test: divisible by 23
        # If true: throw to monkey 2
        # If false: throw to monkey 3

        if($line -match "Monkey (\d+):")
        {
            $currentMonkeyNumber = $line -replace "[^0-9]" , ''
            $ids += $currentMonkeyNumber
        } elseif($line.StartsWith("Starting items:"))
        {
            [int[]]$startItems = ($line -replace "[^0-9`,]" , '') -split ","
            $items += [PSCustomObject]@{
                Number = $currentMonkeyNumber
                Items = $startItems
            }
        } elseif($line.StartsWith("Operation:"))
        {
            $operation += $line -replace "Operation: new = " , ''
        } elseif($line.StartsWith("Test:"))
        {
            $test += $line -replace "Test: divisible by " , ''
        } elseif($line.StartsWith("If true:"))
        {
            $testTrue += $line -replace "If true: throw to monkey " , ''
        } elseif($line.StartsWith("If false:"))
        {
            $testFalse += $line -replace "If false: throw to monkey " , ''
        }
    }

    # Loop through the data and create the monkeys
    foreach($id in $ids)
    {
        $monkey  = [Monkey]::new(
            $id,
            (($items | Where-Object {$_.Number -eq $id}) | Select-Object -ExpandProperty Items),
            $operation[$id],
            $test[$id],
            $testTrue[$id],
            $testFalse[$id]
        )

        $monkeys += $monkey
    }

    return $monkeys
}

function Start-Cycle
{
    param(
        [Monkey[]]$Monkeys
    )

    # Loop through the monkeys
    foreach($monkey in $Monkeys)
    {
        if($monkey.GetNextItem() -eq -1)
        {
            $monkeyNrToSendTo = $monkey.GetMonkeyToSendTo()

            if($monkeyNrToSendTo -ne -1)
            {
                $monkeyToSendTo = $monkeys[$monkeyNrToSendTo]
                $item = $monkey.GetNextItem()
                Send-ItemsToMonkey -from $monkey.Number -to $monkeyToSendTo.Number -items $item
            }
        }
    }

    return $monkeys
}

for($i = 1; $i -le 20; $i++)
{
    $monkeys = Start-Cycle -Monkeys $monkeys

}

# Convert the lines to monkeys
$monkeys = ConvertTo-Monkey -MonkeyLines $lines

$monkeys




