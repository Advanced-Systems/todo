function Remove-TodoList {
    <#
        .SYNOPSIS
        Deletes a TODO list database.

        .DESCRIPTION
        Deletes a TODO list database.

        .PARAMETER User
        Each TODO list is accociated to a user account. The default user account is read from the username environment variable. Specify a value for this parameter to access an another TODO list from a different user.

        .INPUTS
        None. You cannot pipe objects to Remove-TodoList.

        .OUTPUTS
        None.

        .EXAMPLE
        PS C:\> Remove-TodoList
        Remove the default TODO list.

        .EXAMPLE
        PS C:\> Remove-TodoList -User "Mazawa Shinonome"
        Remove the TODO list for a specific user.

        .EXAMPLE
        PS C:\> Get-TodoList | where Status -eq 'Discarded' | Remove-Task -WhatIf
        Dry-run mass removal of all discarded tasks.
    #>
    [Alias("rtodo")]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "High")]
    param(
        [Parameter()]
        [string] $User = $env:USERNAME
    )

    begin {
        $DatabasePath = Join-Path -Path $(Get-SavePath) -ChildPath "${User}.db"
    }
    process {
        if (Test-Path $DatabasePath -IsValid) {
            if ($PSCmdlet.ShouldProcess($DatabasePath)) {
                Remove-Item $DatabasePath
            }
        }
        else {
            Write-Error -Category ObjectNotFound -ErrorAction Stop
        }
    }
    end {}
}
