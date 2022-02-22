function Publish-Todo {
    <#
        .SYNOPSIS
        Test and publish this module.

        .DESCRIPTION
        Test and publish this module. Specify an API key if you intend to publish this module. It is recommended to run the Cmdlet at least once parameterless to perform some preliminary tests.
        This Cmdlet requires the following modules in order to run. Release dependencies are marked with a truthy boolean value.

            Name                Version     Release
            ----                -------     -------
            SQLite              2.0         True
            PSScriptAnalyzer    1.20.0      False
    #>
    [Alias("publish")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter()]
        [string] $ApiKey
    )
    begin {
        $Steps = 5
        $Name = "Todo"
        $ModulePath = $env:PSModulePath -Split ";" | Select-Object -First 1
        $ProjectRootDirectory = Join-Path -Path $PSScriptRoot -ChildPath "src"
        $ManifestPath = Join-Path -Path $ProjectRootDirectory -ChildPath "${Name}.psd1"
        $Manifest = Import-PowerShellDataFile -Path $ManifestPath
        $Version = $Manifest.ModuleVersion
    }
    process {
        Write-Host "(1/${Steps}) Test module manifest" -ForegroundColor Green
        Test-ModuleManifest $ManifestPath

        Write-Host "(2/${Steps}) Import module dependencies" -ForegroundColor Green
        Import-Module SQLite,PSScriptAnalyzer

        Write-Host "(3/${Steps}) Run PSScriptAnalyzer" -ForegroundColor Green
        Invoke-ScriptAnalyzer -Path $ManifestPath

        Write-Host "(4/${Steps}) Import main module" -ForegroundColor Green
        Import-Module $ManifestPath -Force

        Write-Host "(5/${Steps}) Copy items to module directory" -ForegroundColor Green
        $Destination = New-Item -ItemType Directory -Path $ModulePath -Name $Name -Force
        Remove-Item -Recurse -Force $Destination
        Copy-Item $ProjectRootDirectory -Destination $Destination.FullName -Recurse -Force

        if ($PSCmdlet.ShouldProcess($ManifestPath, "Publish ${Name} module version ${Version} to PSGallery")) {
            Publish-Module -Name $Name -NuGetApiKey $ApiKey -Verbose
        }
    }
    end  {
        $UriBuilder = New-Object System.UriBuilder
        $UriBuilder.Scheme = "https"
        $UriBuilder.Host = "www.powershellgallery.com"
        $UriBuilder.Path = @("packages", $Name, $Version -Join "/")
        Start-Process $UriBuilder.ToString()
    }
}
