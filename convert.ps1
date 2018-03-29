
## Step 2 -- test for /design folder
if ( -not (Test-Path -path "./design") ) {
  New-Item -name "design" -path "." -itemType "directory"
}
Write-Host "===`r`n=== Design verified`r`n==="

## Step 3 -- append lines to .gitignore
$nodeStr = "\/node_modules"
$pngStr = "\*.png"

$matchInfo = Select-String -path "./.gitignore" -pattern $nodeStr
if ($matchInfo -eq $null) {
  Write-Output "`r`n**/node_modules" | Out-File -filepath "./.gitignore" -append -encoding "UTF8"
}
$matchInfo = Select-String -path "./.gitignore" -pattern $pngStr
if ($matchInfo -eq $null) {
  Write-Output "`r`n**/*.png" | Out-File -filepath "./.gitignore" -append -encoding "UTF8"  
}
Write-Host "===`r`n===Contents of .gitignore:`r`n==="
Get-Content -path "./.gitignore"
Write-Host "`r`n"

# Step 4 -- Create api-definitions and children
Write-Host "===`r`n===Checking/Creating api-definition folder structure`r`n==="
if ( Test-Path -path "./api-definition") {
  Write-Host "===`r`n=== ./api-definition exists, skipping`r`n==="
} else {
  New-Item -name "api-definition" -path "." -ItemType "directory"
  New-Item -name "bundles" -path "./api-definition" -ItemType "directory"
  New-Item -name "models" -path "./api-definition" -ItemType "directory"
  New-Item -name "paths" -path "./api-definition" -ItemType "directory"
  New-Item -name "schemas" -path "./api-definition" -ItemType "directory"
  New-Item -name "examples" -path "./api-definition" -ItemType "directory"
  Write-Host " ===`r`n=== api-definition structure built`r`n   Remember to add files from existing`r`n   repository`r`n==="
}

# Step 6 -- Copy master definitions.yaml file
$defnFilePath = Resolve-Path -path ".." | Join-Path -childpath "enterpriseapidatamodel/swagger/definitions.yaml"
try {
  Copy-Item -path $defnFilePath -destination "./api-definition"
} catch {
  Write-Host "couldnt do it $error"
}