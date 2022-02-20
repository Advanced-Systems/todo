function Get-TodoList {
    <#
        .SYNOPSIS
        List all tasks from a TODO list.

        .DESCRIPTION
        List all tasks from a TODO list where status is not set to 'Done'. Supply a filter to define custom rules or pipe the output to Where-Object.

        .PARAMETER All
        List all tasks regardless of their current status.

        .PARAMETER Query
        Use a SQL query to perform this operation.

        .PARAMETER User
        Each TODO list is accociated to a user account. The default user account is read from the username environment variable. Specify a value for this parameter to access an another TODO list from a different user.

        .INPUTS
        None. You cannot pipe objects to Get-TodoList.

        .OUTPUTS
        A list of Task objects.

        .EXAMPLE
        PS C:\> Get-TodoList
        List all tasks from the active user TODO list where status is not set to 'Done'. Use the -All switch to list all tasks regardless of their current status.

        .EXAMPLE
        PS C:\> PS C:\> Get-TodoList -All | where Priority -eq 'High'
        List all tasks from the activce user TODO list with a high priority.

        .EXAMPLE
        PS C:\> Get-TodoList -Query "SELECT * FROM TodoList WHERE Priority = 'High'" -User Work
        List all tasks from the Work TODO list with a high priority.
        NOTE: While the SQL query syntax is case-insensitive, search values should be enclosed in single quotes and correctly capitalized. It is highly recommended to use PowerShell's native query methods from the second example to filter results.
    #>
    [Alias("gtodo")]
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = "All")]
        [switch] $All,

        [Parameter(ParameterSetName = "Query", Mandatory = $true)]
        [string] $Query,

        [Parameter()]
        [string] $User = $env:UserName
    )

    begin {
        $SavePath = Join-Path -Path $([Environment]::GetFolderPath("ApplicationData")) -ChildPath "Todo"
        $DatabasePath = Join-Path -Path $SavePath -ChildPath "${User}.db"

        if (-not (Test-Path $DatabasePath)) {
            Write-Error -Message "This TODO list does not exist. You can create one with the command 'New-TodoList -User ${User}'" -Category ObjectNotFound -ErrorAction Stop
        }

        $Connection = New-Object -TypeName "System.Data.SQLite.SQLiteConnection"
        $Connection.ConnectionString = "DATA SOURCE=${DatabasePath}"
        $Connection.Open()
    }
    process {
        $Sql = $Connection.CreateCommand()
        $Sql.CommandText = if ($Query) { $Query } else { "SELECT * FROM TodoList $(if ($All) { '' } else { "WHERE Status != 'Done'" })" }
        $Adapter = New-Object -TypeName "System.Data.SQLite.SQLiteDataAdapter" $Sql
        $Data = New-Object System.Data.DataSet
        [void]$Adapter.Fill($Data)
        $TaskTable = $Data.Tables[0] | ForEach-Object { [Task]::new($_.Id, $_.Project, $_.Description, $_.Priority, $_.Status, $_.StartDate, $_.DueDate) }
        Write-Output $TaskTable
    }
    end {
        $Connection.Close()
        $Sql.Dispose()
    }
}
