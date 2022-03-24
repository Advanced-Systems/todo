function Get-SavePath {
    $SavePath = Join-Path -Path $([Environment]::GetFolderPath("ApplicationData")) -ChildPath "Todo"
    Write-Output $SavePath
}
