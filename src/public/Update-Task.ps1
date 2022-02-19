function Update-Task {
    <#
        .SYNOPSIS
        Update one or more properties of a specific task.

        .DESCRIPTION
        Adds a new task to a TODO list by Id or Query. It is possible to manage multiple TODO lists in separate databases at once.

        .PARAMETER Query
        Use a SQL query to perform this operation.

        .PARAMETER Id
        Defines the ID of a task that is to be updated.

        .PARAMETER Description
        Sets the description of this task.

        .PARAMETER DueDate
        Sets the due date for this task.

        .PARAMETER Priority
        Sets the perceived priority to this task.

        .PARAMETER Project
        Associates this task with a project (group).

        .PARAMETER Status
        Sets the current status to this task.

        .PARAMETER User
        Each TODO list is accociated to a user account. The default user account is read from the username environment variable. Specify a value for this parameter to access an another TODO list from a different user.

        .INPUTS
        None. You cannot pipe objects to Update-Task.

        .OUTPUTS
        None.

        .EXAMPLE
        PS C:\> Update-Task -Id 1 -Status Done
        Mark the first task as done.

        .EXAMPLE
        PS C:\> Update-Task -Id 42 -Priority High -Status InProgress
        Update the priority of task 42 to high and change its current status to in-progress.

        .EXAMPLE
        PS C:\> Update-Task -Query "UPDATE TodoList SET Priority = 'High',Status='InProgress' WHERE Id=42"
        Update the priority of task 42 to high and change its current status to in-progress by using a SQL query.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, ParameterSetName = "Query")]
        [string] $Query,

        [Parameter(Position = 0, Mandatory = $true, ParameterSetName="Property")]
        [int] $Id,

        [Parameter(ParameterSetName = "Property")]
        [string] $Project,

        [Parameter(ParameterSetName = "Property")]
        [string] $Description,

        [Parameter(ParameterSetName = "Property")]
        [ValidateSet("High", "Medium", "Low")]
        [string] $Priority,

        [Parameter(ParameterSetName = "Property")]
        [ValidateSet("TODO", "Idea", "Planning", "InProgress", "Testing", "InReview", "Done", "Discarded", "Blocked")]
        [string] $Status,

        [Parameter(ParameterSetName = "Property")]
        [DateTime] $DueDate,

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
        
        if ($Query) { 
            $Sql.CommandText = $Query 
        } 
        else {
            $QueryBuilder = New-Object System.Collections.Generic.List[string]
            $QueryBuilder.Add("UPDATE TodoList SET ")

            if ($Project) {
                $QueryBuilder.Add("Project = '${Project}'$(if ($Description -or $Priority -or $Status -or $DueDate) {','} else {''})")
            }
            if ($Description) {
                $QueryBuilder.Add("Description = '${Description}'$(if ($Priority -or $Status -or $DueDate) {','} else {''})")
            }
            if ($Priority) {
                $QueryBuilder.Add("Priority = '${Priority}'$(if ($Status -or $DueDate) {','} else {''})")
            }
            if ($Status) {
                $QueryBuilder.Add("Status = '${Status}'$(if ($DueDate) {','} else {''})")
            }
            if ($DueDate) {
                $QueryBuilder.Add("DueDate = '$($DueDate.ToString("yyyy-MM-dd HH:mm:ss.fffffff"))'")
            }

            $QueryBuilder.Add(" WHERE Id=${Id}")
            $Sql.CommandText = $QueryBuilder -Join ''
        }

        if ($PSCmdlet.ShouldProcess($Sql.CommandText)) {
            $Sql.ExecuteNonQuery() | Out-Null
        }
    }
    end {
        $Connection.Close()
        $Sql.Dispose()
    }
}
