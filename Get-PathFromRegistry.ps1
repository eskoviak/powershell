<##
.SYNOPSIS
Reconstructs the ENV:Path entry from the registry keys

.DESCRIPTION

.PARAMETERS

.EXAMPLE

#>
param(

)

# Lambdas
$addPathDelim = {
    param ($path)

    if ( $path[$path.length - 1] -eq ';') {
        return $path
    }
    return $path += ';'
}

#Write-output ( (& $addPathDelim 'abadf;'))

$pwshPath = split-path -path (get-command pwsh).Source -Parent
$SystemPathEnv = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name Path
$UserPathEnv = Get-ItemPropertyValue -Path HKCU:\Environment -Name Path
$combinedPath = (& $addPathDelim $pwshPath) + (& $addPathDelim $SystemPathEnv) + $UserPathEnv
Write-output( $combinedPath )

