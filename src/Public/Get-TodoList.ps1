using namespace System
using namespace System.Data
using namespace System.Data.SQLite
using namespace System.IO

function Get-TodoList {
    <#
        .SYNOPSIS
        List all tasks from a TODO list.

        .DESCRIPTION
        List all tasks from a TODO list where status is not set to 'Done' or 'Discarded'.
        Supply a filter to define custom rules or pipe the output to Where-Object.

        .PARAMETER All
        List all tasks regardless of their current status.

        .PARAMETER Filter
        Use the filter in combination with a comparison operator to apply simple
        filters on this list.

        .PARAMETER User
        Each TODO list is accociated to a user account. The default user account is read from the username environment variable. Specify a value for this parameter to access an another TODO list from a different user.

        .INPUTS
        None. You cannot pipe objects to Get-TodoList.

        .OUTPUTS
        A list of Task objects.

        .EXAMPLE
        PS C:\> Get-TodoList
        List all tasks from the active user TODO list where status is not set to
        'Done'. Use the -All switch to list all tasks regardless of their current
        status.

        .EXAMPLE
        PS C:\> Get-TodoList -All | where Priority -eq 'High'
        List all tasks from the activce user TODO list with a high priority.

        .EXAMPLE
        PS C:\> Get-TodoList -Filter Priority -eq 'High'
        List all tasks from the Work TODO list with a high priority.
    #>
    [Alias("gtodo")]
    [OutputType("Task")]
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName = "All")]
        [switch] $All,

        [Parameter(ParameterSetName = "Filter", Mandatory)]
        [ValidateSet("Id", "Project", "Description", "Priority", "Status", "StartDate", "DueDate")]
        [string] $Filter,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "Equal", Mandatory)]
        [string] $eq,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "NotEqual", Mandatory)]
        [string] $ne,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "GreaterThan", Mandatory)]
        [string] $gt,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "GreaterEqual", Mandatory)]
        [string] $ge,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "LessThan", Mandatory)]
        [string] $lt,

        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "LessEqual", Mandatory)]
        [string] $le,

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
        else {
            $Operator = "<="
            $Value = $le
        }

        $Sql.CommandText = if ($Filter) {
            "SELECT * FROM TodoList WHERE ${Filter} ${Operator} `"${Value}`""
        } else {
            "SELECT * FROM TodoList $($All.IsPresent ? [string]::Empty : "WHERE Status != 'Done' AND Status != 'Discarded'" )"
        }

        try {
            $Adapter = [SQLiteDataAdapter]::new($Sql)
            $Data = [DataSet]::new()
            [void] $Adapter.Fill($Data)

            $TaskTable = $Data.Tables[0] | ForEach-Object {
                [Task]::new(
                    $_.Id,
                    $_.Project,
                    $_.Description,
                    $_.Priority,
                    $_.Status,
                    $_.StartDate,
                    $_.DueDate
                )
            }

            Write-Output $TaskTable
        } catch {
            Write-Error $DatabaseConnectionErrorMessage -Category ConnectionError -ErrorAction Stop
        } finally {
            $Sql.Dispose()
        }
    }
    clean {
        $Connection.Close()
    }
}
