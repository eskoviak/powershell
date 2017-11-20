param(
    [CmdletBinding()]

    [String]$Path = "C:\users\eskov\"
)
New-PSDrive -Name ESC -PSProvider FileSystem -Root $($Path + 'OneDrive - ESC')