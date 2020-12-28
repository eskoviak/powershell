<## 
    .synopsis
        Accepts input from command line as a -like argument for Get-ADComputer


#>

param(
    # $SearchPhrase the search phrase for the computer name
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string]
    $SearchPhrase
)

Get-ADComputer -Filter {Name -like $SearchPhrase} -Properties Whencreated, Whenmodified 
