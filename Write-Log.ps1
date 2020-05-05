# For writing to Elastic

param(
    [Parameter(Mandatory=$true)]
    [String]$env,

    [Parameter(Mandatory=$true)]
    [String]$message
)

$messageHash = @{applicationName="JAMS Scheduler"; logEventLevel="info"; correlationId=""; message=$message; timeStamp=[System.DateTime]::UtcNow.ToString()}
if($env -eq "dev"){
    $url = "http://rwsc-logging-api-dev.cloudhub.io/api/v1/log"
    ConvertTo-Json -InputObject $messageHash -Compress
    Invoke-RestMethod -Uri $url -Method Post -ContentType "application/json" -Body (ConvertTo-Json -InputObject $messageHash -Compress)
}