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
        [string] $User = $env:USERNAME
    )

    begin {
        $SavePath = Join-Path -Path $([Environment]::GetFolderPath("ApplicationData")) -ChildPath "Todo"
        $DatabasePath = Join-Path -Path $SavePath -ChildPath "${User}.db"

        if (-not (Test-Path $DatabasePath)) {
            Write-Error -Message "This TODO list does not exist. You can create one with the command 'New-TodoList -User ${User}'" -Category ObjectNotFound -ErrorAction Stop
        }

        $Connection = New-Object -TypeName System.Data.SQLite.SQLiteConnection
        $Connection.ConnectionString = "DATA SOURCE=${DatabasePath}"
        $Connection.Open()
    }
    process {
        foreach ($i in $Id) {
            $Sql = $Connection.CreateCommand()
            $Sql.CommandText = "DELETE FROM TodoList WHERE Id = ${i}"

            if ($PSCmdlet.ShouldProcess($Sql.CommandText)) {
                $Sql.ExecuteNonQuery() | Out-Null
            }
        }
    }
    end {
        $Connection.Close()
        $Sql.Dispose()
    }
}
