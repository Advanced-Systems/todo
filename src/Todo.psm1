# import classes
if (Test-Path "$PSScriptRoot\classes\classes.psd1") {
    $ClassLoadOrder = Import-PowerShellDataFile -Path "$PSScriptRoot\Classes\classes.psd1" -ErrorAction SilentlyContinue
}

foreach ($class in $ClassLoadOrder.order) {
    $Path = '{0}\classes\{1}.ps1' -f $PSScriptRoot, $class
    if (Test-Path $Path) {
        . $Path
    }
}

# dot source ps1 files
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )

foreach ($Import in @($Public)) {
    try {
        Write-Verbose "Importing $($Import.FullName)"
        . $Import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}

Export-ModuleMember -Function $Public.Basename
