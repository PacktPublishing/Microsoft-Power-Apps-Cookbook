param (
    [string]$fileName,    
    [string]$sourceServer,
    [string]$sourceDatabase,
    [string]$sourceConnectionID,
    [string]$destinationServer,
    [string]$destinationDatabase,
    [string]$destinationConnectionID
)

##################################################################################
#
# .\SQLMigrator.ps1 `
# >> -fileName                '.\Azure SQL Solution.zip' `
# >> -sourceServer            'devServer.database.windows.net' `
# >> -sourceDatabase          'devDatabase' `
# >> -sourceConnectionID      'e22e8d63cf02474fb07207344c93c4dd' `
# >> -destinationServer       'proServer.database.windows.net' `
# >> -destinationDatabase     'proDatabase' `
# >> -destinationConnectionID '079bb382db5b4c8cb92af872bfa0649e'
#
##################################################################################

function UpdateFile {
    param (
        [string]$filePath
    )

    $text = Get-Content "$($filePath)" -Raw
    $text = $text -replace $sourceServer, $destinationServer
    $text = $text -replace $sourceDatabase, $destinationDatabase
    $text = $text -replace $sourceConnectionID, $destinationConnectionID
    $text | Set-Content "$($filePath)"
}

$file = Get-Item $fileName

if ($file.Extension -cne '.zip') { throw 'Only .zip files are allowed' }

$baseFolder = $((Get-Location).Path)
$tempFolder = "$baseFolder\$((Get-Date).ticks)"

Remove-Item $tempFolder -Force -Recurse -ErrorAction SilentlyContinue

# Expand Package
Expand-Archive $file -DestinationPath $tempFolder

# Expand Power App
$app = Get-ChildItem "$($tempFolder)/Microsoft.PowerApps/apps" -Name

$powerApp = Get-ChildItem "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/*.msapp"
$powerApp | Rename-Item -NewName "$($powerApp.Basename).zip"
$powerAppFolder = $powerApp.Basename

Expand-Archive "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/$($powerApp.Basename).zip" -DestinationPath "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/$($powerAppFolder)"

# Update Configuration files
UpdateFile "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/$($app).json"
UpdateFile "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/$($powerAppFolder)/Properties.json"
UpdateFile "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/$($powerAppFolder)/References/DataSources.json"

# Compress Power App and Clean Up
Set-Location "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/$($powerAppFolder)"
Compress-Archive -Path "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/$($powerAppFolder)\*" -DestinationPath "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/$($powerApp.Basename).zip" -Update
Rename-Item -Path "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/$($powerApp.Basename).zip" -NewName "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/$($powerApp.Basename).msapp"

Set-Location "$($tempFolder)/Microsoft.PowerApps/apps/$($app)"
Remove-Item "$($tempFolder)/Microsoft.PowerApps/apps/$($app)/$($powerAppFolder)" -Force -Recurse -ErrorAction SilentlyContinue

# Compress Package and Clean Up
Set-Location $tempFolder
Compress-Archive -Path "$tempFolder\*" -DestinationPath "$baseFolder\$($file.Basename)-migrated.zip" -Update

Set-Location $baseFolder
Remove-Item $tempFolder -Force -Recurse -ErrorAction SilentlyContinue