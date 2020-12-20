param (
    [string]$fileName,
    [string]$siteUrl,
    [string]$listId,
    [string]$listUrl
)

##############################################################################################################
#
# .\SPListTransform.ps1 `
# >> -fileName '.\PowerPlatform.zip' `
# >> -siteUrl  'https://ampicurrents.sharepoint.com/sites/Production' `
# >> -listId   '6ddcd69c-9eb2-4a71-8924-1f392570fe5d' `
# >> -listUrl  'https://ampicurrents.sharepoint.com/sites/Production/Lists/Power Platform/AllItems.aspx' `
#
##############################################################################################################

$file = Get-Item $fileName

if($file.Extension -cne '.zip') { throw 'Only .zip files are allowed'}

$baseFolder = $((Get-Location).Path)
$tempFolder = "$baseFolder\$((Get-Date).ticks)"

Remove-Item $tempFolder -Force -Recurse -ErrorAction SilentlyContinue

Expand-Archive $fileName -DestinationPath $tempFolder

$app = Get-ChildItem "$($tempFolder)/Microsoft.PowerApps/apps" -Name
$text = Get-Content "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/$($app).json" -Raw
$text = $text -replace '\"siteId\"\:\s*\"(.*?)\"', "`"siteId`":`"$siteUrl`"" 
$text = $text -replace '\"listId\"\:\s*\"(.*?)\"', "`"listId`":`"$listId`""
$text = $text -replace '\"listUrl\"\:\s*\"(.*?)\"', "`"listUrl`":`"$listUrl`""
$text | Set-Content "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/$($app).json"

Set-Location $tempFolder
Compress-Archive -Path "$tempFolder\*" -DestinationPath "$baseFolder\Result.zip" -Update

Set-Location $baseFolder
Remove-Item $tempFolder -Force -Recurse -ErrorAction SilentlyContinue