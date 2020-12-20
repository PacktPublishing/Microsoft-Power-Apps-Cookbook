param (
    [string]$fileName
)

[convert]::ToBase64String((Get-Content -Path $fileName -Encoding Byte)) | Out-File "result.txt"