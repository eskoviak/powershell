<##
    .synopsis
        Reads the device name, and if found updateds the Complete date with the whenCreated property from the computer
        record

#>
param(

)

$PackagePath = 'C:\Program Files\PackageManagement\NuGet\Packages\Microsoft.SharePoint.Client.dll.15.0.4420.1017'

#Load SharePoint CSOM Assemblies
Add-Type -Path (Join-Path -Path $PackagePath -ChildPath "Microsoft.SharePoint.Client.dll")
Add-Type -Path (Join-Path -Path $PackagePath -ChildPath "Microsoft.SharePoint.Client.Runtime.dll")

#Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
#Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
    
#Variables for Processing
$SiteUrl = "https://redwingshoes.sharepoint.com/sites/TM_BT_Recovery"
$FileRelativeURL ="https://redwingshoes.sharepoint.com/sites/TM_BT_Recovery/Shared Documents/General/Workstation Recovery/AD User List_with_device_status Master.xlsx"
 
#Get Credentials to connect
$Cred = Get-Credential
  
Try {
    #Set up the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
    exit
    $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.UserName,$Cred.Password)
  
    #powershell get file from sharepoint online
    $File = $Ctx.web.GetFileByServerRelativeUrl($FileRelativeURL)
    $Ctx.Load($File)
    $Ctx.ExecuteQuery()
  
    Write-host "File Size:" ($File.Length/1KB)
}
catch {
    write-host "Error: $($_.Exception.Message)" -Foregroundcolor Red
    Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Blue
}


#Read more: https://www.sharepointdiary.com/2018/08/sharepoint-online-powershell-to-get-file.html#ixzz6gu4XbSnr