using namespace System
using namespace System.Data.SQLite
using namespace System.IO

function Remove-Task {
    <#
        .SYNOPSIS
        Remove a task from a TODO list.

        .DESCRIPTION
        Remove a task from a TODO list by Id.

        .PARAMETER Id
        Defines the ID of a task that is to be removed.

        .PARAMETER User
        Each TODO list is accociated to a user account. The default user account is read from the username environment variable. Specify a value for this parameter to access an another TODO list from a different user.

        .INPUTS
        You can pipe Task objects to Remove-Task.

        .OUTPUTS
        None.

        .EXAMPLE
        PS C:\> Remove-Task 23
        Remove a task whose Id equals 23.

        .EXAMPLE
        PS C:\> Get-TodoList -All | where Status -eq 'Done' | Remove-Task -WhatIf
        Remove all tasks from the current user's TODO list that were marked as done.
    #>
    [Alias("rtask")]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory, ValueFromPipelineByPropertyName)]
        [int[]] $Id,

        [Parameter()]
        [string] $User = [Environment]::UserName
    )

    begin {
        $SavePath = Get-SavePath
        $DatabasePath = [Path]::Combine($SavePath, "${User}.db")

        if (!(Test-Path $DatabasePath)) {
            Write-Error $DatabaseDoesNotExistErrorMessage -Category ObjectNotFound -ErrorAction Stop
        }

        $Connection = [SQLiteConnection]::new()
        $Connection.ConnectionString = "DATA SOURCE=${DatabasePath}"
        $Connection.Open()
    }
    process {
        foreach ($i in $Id) {
            $Sql = $Connection.CreateCommand()
            $Sql.CommandText = "DELETE FROM TodoList WHERE Id = ${i}"

            if ($PSCmdlet.ShouldProcess($Sql.CommandText)) {
                try {
                    $Sql.ExecuteNonQuery() | Out-Null
                } catch {
                    Write-Error $DatabaseConnectionErrorMessage -Category ConnectionError -ErrorAction Stop
                } finally {
                    $Sql.Dispose()
                }
            }
        }
    }
    clean {
        $Connection.Close()
    }
}
