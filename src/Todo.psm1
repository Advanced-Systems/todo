if (Test-Path "${PSScriptRoot}\classes\classes.psd1") {
    $ClassLoadOrder = Import-PowerShellDataFile -Path "${PSScriptRoot}\classes\classes.psd1" -ErrorAction SilentlyContinue
}

foreach ($Class in $ClassLoadOrder.Order) {
    $Path = '{0}\classes\{1}.ps1' -f $PSScriptRoot, $Class
    if (Test-Path $Path) {
        . $Path
    }
}

$Public = @( Get-ChildItem -Path "${PSScriptRoot}\public\*.ps1" -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path "${PSScriptRoot}\private\*.ps1" -ErrorAction SilentlyContinue )

foreach ($Import in @($Public + $Private)) {
    try {
        Write-Verbose "Importing $($Import.FullName)"
        . $Import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

Export-ModuleMember -Function $Public.Basename -Alias *

Get-ChildItem -Path "$PSScriptRoot/init" | ForEach-Object {
    Write-Verbose "Initializing $($_.Name)"
    . $_.FullName
}
