function Get-TodoList {
    <#
        .SYNOPSIS
        List all tasks from a TODO list.

        .DESCRIPTION
        List all tasks from a TODO list where status is not set to 'Done'. Supply a filter to define custom rules or pipe the output to Where-Object.

        .PARAMETER All
        List all tasks regardless of their current status.

        .PARAMETER Filter
        Use the filter in combination with a comparison operator to apply simple filters on this list.

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
        PS C:\> Get-TodoList -Filter Priority -eq 'High'
        List all tasks from the Work TODO list with a high priority.
    #>
    [Alias("gtodo")]
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = "All")]
        [switch] $All,

        [Parameter(ParameterSetName = "Filter", Mandatory = $true)]
        [ValidateSet("Id", "Project", "Description", "Priority", "Status", "StartDate", "DueDate")]
        [string] $Filter,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "Equal", Mandatory = $true)]
        [string] $eq,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "NotEqual", Mandatory = $true)]
        [string] $ne,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "GreaterThan", Mandatory = $true)]
        [string] $gt,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "GreaterEqual", Mandatory = $true)]
        [string] $ge,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "LessThan", Mandatory = $true)]
        [string] $lt,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "LessEqual", Mandatory = $true)]
        [string] $le,

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

        if ($eq) {
            $Operator = "="
            $Value = $eq
        }
        elseif ($ne) {
            $Operator = "<>"
            $Value = $ne
        }
        elseif ($gt) {
            $Operator = ">"
            $Value = $gt
        }
        elseif ($ge) {
            $Operator = ">="
            $Value = $ge
        }
        elseif ($lt) {
            $Operator = "<"
            $Value = $lt
        }
        elseif ($le) {
            $Operator = "<="
            $Value = $le
        }

        $Sql.CommandText = if ($Filter) { "SELECT * FROM TodoList WHERE ${Filter} ${Operator} '${Value}'" } else { "SELECT * FROM TodoList $(if ($All) { '' } else { "WHERE Status != 'Done'" })" }
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
