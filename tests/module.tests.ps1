using namespace System.IO

param(
    [string] $ModuleName = "Todo",

    [string] $Version,

    [switch] $Build
)

$ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Path
$ProjectRoot = $(Get-Item $([Path]::Combine($ScriptPath, ".."))).FullName

if ($Build.IsPresent) {
    & $([Path]::Combine($ProjectRoot, "Scripts", "build.ps1")) -Version $Version
}

Import-Module -Name $([Path]::Combine($ProjectRoot, "src", "${ModuleName}.psd1")) `
    -ErrorAction Stop `
    -PassThru

#region Unit Tests

Describe "Foo" {
    Context "Bar" {
        It "Should pass" {
            $true | Should -Be $true -Because "it is true"
        }
    }
}

#endregion
