function Remove-Task {
    <#
        .SYNOPSIS
        Remove a task from a TODO list.

        .DESCRIPTION
        Remove a task from a TODO list by Id or Query.

        .PARAMETER Query
        Use a SQL query to perform this operation.

        .PARAMETER Id
        Defines the ID of a task that is to be removed.

        .PARAMETER User
        Each TODO list is accociated to a user account. The default user account is read from the username environment variable. Specify a value for this parameter to access an another TODO list from a different user.

        .INPUTS
        None. You cannot pipe objects to Update-Task.

        .OUTPUTS
        None.

        .EXAMPLE
        PS C:\> Remove-Task -Id 23
        Remove a task where Id equals the value of 23.

        .EXAMPLE
        PS C:\> Remove-Task -Query "DELETE FROM TodoList WHERE Status = 'Done'"
        Remove all tasks from the current user's TODO list that were marked as done.

        .EXAMPLE
        PS C:\> Remove-Task -Query "DELETE FROM TodoList WHERE Project = 'Confluence'" -User Work
        Use a SQL query to remove all tasks from the work database that were originally assigned to the Confluence project.
        NOTE: String values should be enclosed by single quotes.
        WARNING: This operation is irreversible.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = "Id")]
        [int] $Id,

        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = "Query")]
        [string] $Query,

        [Parameter()]
        [string] $User = $env:UserName
    )

    begin {
        $SavePath = Join-Path -Path $([Environment]::GetFolderPath("ApplicationData")) -ChildPath "Todo"
        $DatabasePath = Join-Path -Path $SavePath -ChildPath "${User}.db"
        $Connection = New-Object -TypeName "System.Data.SQLite.SQLiteConnection"
        $Connection.ConnectionString = "DATA SOURCE=${DatabasePath}"
        $Connection.Open()
    }
    process {
        $Sql = $Connection.CreateCommand()
        $Sql.CommandText = if ($Query) { $Query } else { "DELETE FROM TodoList WHERE Id = ${Id}" }

        if ($PSCmdlet.ShouldProcess($Sql.CommandText)) {
            $Sql.ExecuteNonQuery() | Out-Null
        }
    }
    end {
        $Connection.Close()
        $Sql.Dispose()
    }
}
