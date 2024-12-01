using namespace System
using namespace System.IO

function Remove-TodoList {
    <#
        .SYNOPSIS
        Deletes a TODO list database.

        .DESCRIPTION
        Deletes a TODO list database.

        .PARAMETER User
        Each TODO list is associated to a user account. The default user account
        is read from the username environment variable. Specify a value for this
        parameter to access an another TODO list from a different user.

        .INPUTS
        None. You cannot pipe objects to Remove-TodoList.

        .OUTPUTS
        None.

        .EXAMPLE
        PS C:\> Remove-TodoList
        Remove the default TODO list.

        .EXAMPLE
        PS C:\> Remove-TodoList -User "Stefan Greve"
        Remove the TODO list for a specific user.

        .EXAMPLE
        PS C:\> Get-TodoList | where Status -eq 'Discarded' | Remove-Task -WhatIf
        Dry-run mass removal of all discarded tasks.
    #>
    [Alias("rtodo")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter()]
        [string] $User = [Environment]::UserName
    )

    begin {
        $SavePath = Get-SavePath
        $DatabasePath = [Path]::Combine($SavePath, "${User}.db")

        if (!(Test-Path $DatabasePath)) {
            Write-Error $DatabaseDoesNotExistErrorMessage -Category ObjectNotFound -ErrorAction Stop
        }
    }
    process {
        if ($PSCmdlet.ShouldProcess($DatabasePath)) {
            Remove-Item $DatabasePath
        }
    }
    clean {}
}
