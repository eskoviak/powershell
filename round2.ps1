$adminUPN="eskoviak@eskoviak.net" 
#$adminURL = "https://eskoviak-admin.sharepoint.com" 
#$orgName="myorgsite.onmicrosoft.com" 
#$userCredential = Get-Credential -UserName $adminUPN -Message "Type the password." 
#Connect-SPOService -Url $adminURL -Credential $userCredential


#[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
$secureCredential = ConvertTo-SecureString "D3nv3rC010" -AsPlainText -Force

$SiteURL = "https://eskoviak-admin.sharepoint.com"

[Microsoft.SharePoint.Client.ClientContext]$cc = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
[Microsoft.SharePoint.Client.SharePointOnlineCredentials]$spocreds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($adminUPN, $secureCredential) 
$cc.Credentials = $spocreds 
$sideLoadingEnabled = [Microsoft.SharePoint.Client.appcatalog]::IsAppSideloadingEnabled($cc)
$cc.ExecuteQuery()

if($sideLoadingEnabled.value -eq $false) {
Write-Host -ForegroundColor Yellow "SideLoading feature is not enabled on the site: $($SiteURL)"
$site = $cc.Site;
$sideLoadingGuid = new-object System.Guid "AE3A1339-61F5-4f8f-81A7-ABD2DA956A7D"
$site.Features.Add($sideLoadingGuid, $false, [Microsoft.SharePoint.Client.FeatureDefinitionScope]::None); $cc.ExecuteQuery();
Write-Host -ForegroundColor Green "SideLoading feature enabled on site $($SiteURL)"
}

Else {
Write-Host -ForegroundColor Green 'SideLoading feature is already enabled on site'
}